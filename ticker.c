//
// Ticker
// Adam R. Nelson (adam@sector91.com)
// June 2013
//
// A simple UNIX terminal program that creates a "news
// ticker" effect when called repeatedly. Allows long
// strings of data to be displayed in narrow spaces in
// "monitor" applications (Conky, panels, etc).
//
// Distributed under the BSD License.
//
// --------------------------------------------------------

#include <locale.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <sys/time.h>

#define CHECK_NULL(var) if (var == NULL) return NULL;

// Option parsing
// --------------------------------------------------------

#define SW_ALWAYS_SHORT  'a'
#define SW_ALWAYS_LONG   "always-scroll"
#define SW_BLANK_SHORT   'b'
#define SW_BLANK_LONG    "blank"
#define SW_LEN_SHORT     'l'
#define SW_LEN_LONG      "length"
#define SW_REVERSE_SHORT 'r'
#define SW_REVERSE_LONG  "reverse"
#define SW_TICK_SHORT    't'
#define SW_TICK_LONG     "tick"

#define DEFAULT_BLANK L' '
#define DEFAULT_LEN   80
#define DEFAULT_TICK  100

typedef struct Options
{
    bool     always_scroll;
    wchar_t  blank;
    uint16_t length;
    bool     reverse;
    uint32_t tick;
}
Options;

Options options; // Global options variable.

// Prints a help/usage message.
void help(char* name)
{
    fprintf(stderr, "Usage: %s [OPTION]...\n\n"
        
        "  -%c, --" SW_ALWAYS_LONG "\n"
        "        Always scroll, even when the input length is less than the\n"
        "        ticker length.\n"
        "  -%c char, --" SW_BLANK_LONG "=char\n"
        "        Fill blank space with 'char'. Defaults to '%lc'.\n"
        "  -%c N, --" SW_LEN_LONG "=N\n"
        "        The length, in columns, of the output. Defaults to %d.\n"
        "  -%c, --" SW_REVERSE_LONG "\n"
        "        Scroll from left to right, instead of the default (right to\n"
        "        left).\n"
        "  -%c ms, --" SW_TICK_LONG "=ms\n"
        "        The amount of time, in milliseconds, it takes for the\n"
        "        ticker to move by one character. Defaults to %d.\n\n"
        
        "Takes a string from standard input, and outputs a portion of it to\n"
        "standard output. The portion output depends on the current system\n"
        "time. When called repeatedly over time with the same input, creates\n"
        "a scrolling 'news ticker' effect.\n\n"

        "Written by Adam R. Nelson <http://github.com/ar-nelson>.\n"
        "Distributed under the BSD License.\n"
        "Post bug reports on GitHub, or send them to <adam@sector91.com>.\n"
        "(Be sure to include 'ticker' in the 'Subject' field of emails.)\n",
        name,
        SW_ALWAYS_SHORT,
        SW_BLANK_SHORT, DEFAULT_BLANK,
        SW_LEN_SHORT, DEFAULT_LEN,
        SW_REVERSE_SHORT,
        SW_TICK_SHORT, DEFAULT_TICK);
}

uint8_t parse_short_option(char opt, char* value);
bool parse_long_option(char* opt);

// Parses command-line arguments into the global 'options'
// struct. Returns false if the arguments are invalid.
bool parse_options(int argc, char** argv)
{
    options.always_scroll = false;
    options.blank   = DEFAULT_BLANK;
    options.length  = DEFAULT_LEN;
    options.reverse = false;
    options.tick    = DEFAULT_TICK;
    int i = 1;
    while (i < argc)
    {
        char* arg = argv[i];
        if (strlen(arg) < 2)
            return false;
        if (arg[0] == '-')
        {
            if (arg[1] == '-')
            {
                if (!parse_long_option(arg))
                {
                    printf("Invalid argument: '%s'\n", arg);
                    return false;
                }
                i += 1;
            }
            else
            {
                size_t len = strlen(arg);
                char* next = (i < argc-1) ? argv[i+1] : NULL;
                uint8_t res;
                for (size_t c=1; c<len; c++)
                {
                    res = parse_short_option(arg[c], next);
                    if (res == 0 || (c < len-1 && res > 1))
                    {
                        printf("Invalid argument or value for '-%c'\n", arg[c]);
                        return false;
                    }
                }
                i += res;
            }
        }
        else
        {
            printf("Invalid argument: '%s'\n", arg);
            return false;
        }
    }
    return true;
}

// Attempts to parse a short-form option (single letter
// preceded by a single dash, followed by a space and a
// value). Returns the number of arguments "consumed" (1 or
// 2, depending on whether the option takes a value), or
// 0 if the arguments are invalid.
uint8_t parse_short_option(char opt, char* value)
{
    switch (opt)
    {
    case SW_ALWAYS_SHORT:
        options.always_scroll = true;
        return 1;
    case SW_BLANK_SHORT:
        if (value == NULL || mbtowc(&options.blank, value, 4) == -1)
            return 0;
        return 2;
    case SW_LEN_SHORT:
        if (value == NULL || (options.length = atoi(value)) == 0)
            return 0;
        return 2;
    case SW_REVERSE_SHORT:
        options.reverse = true;
        return 1;
    case SW_TICK_SHORT:
        if (value == NULL || (options.tick = atoi(value)) == 0)
            return 0;
        return 2;
    default:
        return 0;
    }
}

// Attempts to parse a long-form option (two dashes
// followed by a word, an equals sign, and a value).
// Returns true on success, false on failure.
bool parse_long_option(char* opt)
{
    char* name  = strtok(opt,  "=") + 2;
    char* value = strtok(NULL, "=");
    if (strcmp(name, SW_ALWAYS_LONG) == 0)
    {
        options.always_scroll = true;
        return true;
    }
    else if (strcmp(name, SW_BLANK_LONG) == 0)
    {
        if (value == NULL || mbtowc(&options.blank, value, 4) == -1)
            return false;
        return true;
    }
    else if (strcmp(name, SW_LEN_LONG) == 0)
    {
        if (value == NULL || (options.length = atoi(value)) == 0)
            return false;
        return true;
    }
    else if (strcmp(name, SW_REVERSE_LONG) == 0)
    {
        options.reverse = true;
        return true;
    }
    else if (strcmp(name, SW_TICK_LONG) == 0)
    {
        if (value == NULL || (options.tick = atoi(value)) == 0)
            return false;
        return true;
    }
    else
        return false;
}

// Linked-buffer data structure
//
// A linked list of buffers, used to allocate potentially
// endless space for input.
// --------------------------------------------------------

#define BUF_SIZE 1024
#define MAX_CHAIN_LEN 128

typedef struct LinkedBuffer
{
    wchar_t buf[BUF_SIZE];
    struct LinkedBuffer* next;
}
LinkedBuffer;

// Allocates a new linked buffer. It is the caller's
// responsibility to free the newly-allocated buffer.
LinkedBuffer* create_linked_buffer()
{
    LinkedBuffer* newbuf = malloc(sizeof(LinkedBuffer));
    CHECK_NULL(newbuf);
    newbuf->next = NULL;
    return newbuf;
}

// Collapses a linked chain of buffers into a single
// contiguous block of memory. This frees the entire linked
// buffer chain, but also allocates a new block of memory
// (the returned wchar_t*) that must be freed.
wchar_t* collapse_linked_buffer(LinkedBuffer* buf, size_t chainlen)
{
    LinkedBuffer* current = buf;
    wchar_t* flatbuf = malloc(chainlen*BUF_SIZE*sizeof(wchar_t));
    CHECK_NULL(flatbuf);
    flatbuf[0] = L'\0';
    for (size_t i=0; i<chainlen; i++)
    {
        wcscat(flatbuf, current->buf);
        LinkedBuffer* last = current;
        current = current->next;
        free(last);
    }
    return flatbuf;
}

// Reads an unlimited number of characters from a stream
// until EOF, and returns a malloc'd block of memory
// containing the characters read. It is the caller's
// responsibility to free this block.
wchar_t* read_from_stream(FILE* stream)
{
    // Try setting the locale to UTF-8 a few different ways.
    if (setlocale(LC_CTYPE, "") == NULL)
        if (setlocale(LC_CTYPE, "UTF-8") == NULL)
            setlocale(LC_CTYPE, NULL); // If this doesn't work, just give up.

    LinkedBuffer* rootbuf = create_linked_buffer();
    CHECK_NULL(rootbuf);
    LinkedBuffer* current = rootbuf;
    size_t chainlen = 1;
    while(chainlen < MAX_CHAIN_LEN)
    {
        fgetws(current->buf, BUF_SIZE, stream);
        if (ferror(stream))
        {
            perror("Error reading input");
            exit(EXIT_FAILURE);
        }
        if (feof(stream))
            break;
        LinkedBuffer* next = create_linked_buffer();
        CHECK_NULL(next);
        current->next = next;
        current = next;
        chainlen++;
    }
    return collapse_linked_buffer(rootbuf, chainlen);
}

// Output processing
// --------------------------------------------------------

// Retrieves the current system time in milliseconds since
// the epoch.
uint64_t current_time_ms()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (tv.tv_sec) * 1000 + (tv.tv_usec) / 1000;
}

// Replaces the region of 'str' from 'start' to 'end-1'
// with the blank character defined in the global 'options'
// struct.
void fill_with_blanks(wchar_t* str, size_t start, size_t end)
{
    for (size_t i=start; i<end; i++)
        str[i] = options.blank;
}

// The main entry point of the program.
// This is where the magic happens.
// --------------------------------------------------------
int main(int argc, char** argv)
{
    // Parse the command-line options.
    if (!parse_options(argc, argv))
    {
        help(argv[0]);
        return EXIT_FAILURE;
    }

    // Read from standard input.
    wchar_t* input = read_from_stream(stdin);
    if (input == NULL) goto out_of_memory;
    size_t len = wcslen(input);

    // Chomp a trailing newline.
    if (len > 0 && input[len-1] == L'\n')
    {
        input[len-1] = L'\0';
        len--;
    }

    // Allocate space for the output string.
    wchar_t* output = malloc(sizeof(wchar_t)*(options.length+1));
    if (output == NULL)
    {
        free(input);
        goto out_of_memory;
    }

    // If the input is shorter than the ticker width, just
    // return the input.
    if (!options.always_scroll && len <= options.length)
    {
        memcpy(output, input, sizeof(wchar_t)*len);
        fill_with_blanks(output, len, options.length);
    }

    // Otherwise, clip the output and offset it by the
    // modulus of the current UNIX timestamp.
    else
    {
        ssize_t end = (current_time_ms()/options.tick) % (len+options.length);
        if (options.reverse) end = (len+options.length)-end;
        ssize_t start = end - options.length;
        if (start < 0)
        {
            fill_with_blanks(output, 0, -start);
            memcpy(output-start, input, end*sizeof(wchar_t));
            if (options.always_scroll && end > len)
                fill_with_blanks(output, options.length-(end-len),
                                         options.length);
        }
        else
        {
            if (end > len)
            {
                ssize_t overflow = end - len;
                fill_with_blanks(output, options.length-overflow,
                                         options.length);
                end = len;
            }
            memcpy(output, input+start, (end-start)*sizeof(wchar_t));
        }
    }
    free(input);

    // Convert the output buffer back to the native
    // encoding and output it.
    output[options.length] = L'\0';
    wprintf(output);
    free(output);

    return EXIT_SUCCESS;

out_of_memory:
    fputs("ERROR\n", stdout);
    fputs("Out of memory.\n", stderr);
    return EXIT_FAILURE;
}

