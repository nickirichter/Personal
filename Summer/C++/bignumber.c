
#include <stdlib.h>
#include <stdio.h>

struct BigNumber {
    int n; // number of segments
    unsigned * segments;
};  

/*
 * initBigNumber( struct BigNumber * )
 * Initialize a null BigNumber struct to contain a single segment.
 */
void initBigNumber( struct BigNumber * bigNumber ) {
    if ( !bigNumber ) return;
    bigNumber->segments = malloc( 1 * sizeof( unsigned ) );
    bigNumber->segments[ 0 ] = 0;
    bigNumber->n = 1;
}

/*
 * deleteBigNumber( struct BigNumber * )
 * Deallocate all memory held by the BigNumber,
 * rendering the BigNumber null.
 */
void deleteBigNumber( struct BigNumber * bigNumber ) {
    if ( !bigNumber ) return;
    if ( bigNumber->segments ) {
        free( bigNumber->segments );
        bigNumber->segments = 0;
        bigNumber->n = 0;
    }
}

/*
 *  bigNumberToString( struct BigNumber *, char *, int ) 
 *  NOTE: If a buffer larger than numchars is required, 
 *        then the generated string will be a truncated version of the true
 *        value, indicated by a trailing "...".
 *  NOTE2: This function assumes 4-byte ints
 */
void bigNumberToString( struct BigNumber * bigNumber, char * buf, int numchars ) {
    // Handle tiny string buffer 
    if ( numchars < 10 ) {
        snprintf( buf, numchars, "---" );
    // Null BigNumber
    } else if ( !bigNumber || bigNumber->n == 0 ) {
        snprintf( buf, numchars, "0x00" );
    } else {
        unsigned i = 0; // index into buf
        // Write hex prefix
        sprintf( &buf[ i ], "0x" );
        i+=2;
        // Find last non-zero segment
        int n = bigNumber->n - 1 ;
        while ( bigNumber->segments[ n ] == 0 && n > 0 ) {
            n--;
        }
        // Write bytes from most significant to least -- writes 8 hex digits each iteration
        for ( ; n>=0; n-- ) {
            // Detect end of buffer -- append "..." to indicate truncated string
            if ( i > numchars - 10 ) {
                if ( i > numchars - 4 ) i = numchars - 4;
                sprintf( &buf[i], "..." );
                return;
            }
            sprintf( &buf[ i ], "%08x", bigNumber->segments[ n ] );
            i+=8;
        }
        // Write final null char
        buf[ i ] = 0;
    }
}

void printBigNumber( struct BigNumber * bigNumber ) {
    char buf[ 1000 ];
    bigNumberToString( bigNumber, buf, sizeof( buf ) );
    printf( "%s\n", buf );
}

void expandBigNumber( struct BigNumber * bigNumber ) {
    if ( !bigNumber ) return; 
    if ( !bigNumber->segments ) return;
    // Allocate new segments array
    int newN = bigNumber->n * 2;
    unsigned * newSegments = malloc( newN * sizeof( unsigned ) );
    // Initialize new segments array
    unsigned i;
    for ( i=0; i<bigNumber->n; i++ ) {
        newSegments[ i ] = bigNumber->segments[ i ];
    }
    for ( ; i<newN; i++ ) {
        newSegments[ i ] = 0;
    }
    // Save reference to old segments array
    unsigned * victimSegments = bigNumber->segments;
    // Point bigNumber to new segments
    bigNumber->segments = newSegments;
    bigNumber->n = newN;
    // Free old segments array
    if ( victimSegments ) free( victimSegments );
}

void setBigNumber( struct BigNumber * bigNumber, unsigned u ) {
    if ( !bigNumber ) return;
    unsigned i;
    for ( i=0; i<bigNumber->n; i++ ) {
        bigNumber->segments[ i ] = 0;
    }
    bigNumber->segments[ 0 ] = u;
}

void copyBigNumber( struct BigNumber * destination, struct BigNumber * source ) {
    if ( !destination || destination->n == 0 ) return;
    if ( !source || source->n == 0 ) return;

    while ( destination->n < source->n ) expandBigNumber( destination );
    int i;
    for ( i=0; i<source->n; i++ ) {
        destination->segments[ i ] = source->segments[ i ];
    }
}

// Sets value of target: target = a + b
void addBigNumber( struct BigNumber * target, struct BigNumber * a, struct BigNumber * b ) {
    // Inputs cannot be null
    if ( !target || !a || !b ) return;
    // inputs cannot be uninitialized
    if ( target->n == 0 || a->n == 0 || b->n == 0 ) return;
    // Enforce that a has no fewer segments than b -- This simplifies the upcoming logic.
    if ( a->n < b->n ) {
        struct BigNumber * temp = a;
        a = b;
        b = temp;
    }
    // Reset target's value
    setBigNumber( target, 0 );

    // Add a and b segment-by-segment
    unsigned i;
    unsigned overflow = 0;
    for ( i=0; i<b->n; i++ ) {
        //printf( "%u :  %x + %x + %x\n", i, overflow, a->segments[ i ], b->segments[ i ] );
        // Add into 8-byte value to capture overflow
        long unsigned temp_a = a->segments[ i ];
        long unsigned temp_b = b->segments[ i ];
        long unsigned temp_over = overflow;
        long unsigned temp_sum = temp_over + temp_a + temp_b;
        //long unsigned temp = overflow + a->segments[ i ] + b->segments[ i ];
        //printf( "     SUM : 0x%016lx\n", temp_sum ); 
        //printf( "     OVF : 0x%016lx\n", temp_sum & 0xffffffff00000000 ); 
        //printf( "     VAL : 0x%016lx\n", temp_sum & 0x00000000ffffffff ); 
        // Separate sum into segment value and overflow
        overflow = temp_sum >> 32;
        unsigned segmentValue = temp_sum & 0xffffffff;
        //printf( "      overflow : %x   segment : %x\n", overflow, segmentValue );
        // Expand target if necessary
        while ( target->n <= i ) expandBigNumber( target );
        // Set segment value
        target->segments[ i ] = segmentValue;
    }
    // Add leftover a segments -- Because we know that if either BigNumber has more segments, it must be a.
    for ( ; i<a->n; i++ ) {
        //printf( "%u :  %x + %x\n", i, overflow, a->segments[ i ] );
        // Add into 8-byte value to capture overflow
        long unsigned temp_a = a->segments[ i ];
        long unsigned temp_over = overflow;
        long unsigned temp_sum = temp_over + temp_a;
        // Separate sum into segment value and overflow
        overflow = temp_sum >> 32;
        unsigned segmentValue = temp_sum & 0xffffffff;
        // Set segment value
        while ( target->n <= i ) expandBigNumber( target );
        target->segments[ i ] = segmentValue;
    }
    // Add leftover overflow
    if ( overflow > 0 ) {
        //printf( "%u :  %x\n", i, overflow );
        while ( target->n <= i ) expandBigNumber( target );
        target->segments[ i ] = overflow;
    }
}


// Assigns the value of fib(n) to the BigNumber object
// referenced by 'retval'.
// retval must be an initialized BigNumber struct.
void bigFib( struct BigNumber * retval, unsigned n ) {
    if ( !retval|| retval->n == 0 ) return;
    // Handle n = 0 or n = 2
    if ( n == 0 ) {
        setBigNumber( retval, 0 );
        return;
    } else if ( n == 1 ) {
        setBigNumber( retval, 1 );
        return;
    }
  
    struct BigNumber numbers[3];
    int i1 = 0;
    int i2 = 1;
    int i3 = 2;
    struct BigNumber * a;
    struct BigNumber * b;
    struct BigNumber * c;
    a = &numbers[ i1 ];
    b = &numbers[ i2 ];
    c = &numbers[ i3 ];
    initBigNumber( a );
    initBigNumber( b );
    initBigNumber( c );
    setBigNumber( a, 0 );
    setBigNumber( b, 1 );
    int i;

    for ( i=2; i<=n; i++ ) {
        addBigNumber( c, a, b ); 

        i1 = (i1 + 1) % 3;
        i2 = (i2 + 1) % 3;
        i3 = (i3 + 1) % 3;

        a = &numbers[ i1 ];
        b = &numbers[ i2 ];
        c = &numbers[ i3 ];
    }
    copyBigNumber( retval, b );
    deleteBigNumber( a );
    deleteBigNumber( b );
    deleteBigNumber( c );
}

void usage( int argc, char ** argv ) {
    printf( "USAGE:\n" );
    printf( "%s N\n", argv[ 0 ] );
    printf( "\n" );
    printf( "PARAMETERS:\n" );
    printf( "N      Fibonacci number to calculate\n" );
    printf( "\n" );
}

int main( int argc, char ** argv ) {
    // Check number of command line arguments
    if ( argc != 2 ) {
        fprintf( stderr, "ERROR: Incorrect number of arguments.\n\n" );
        usage( argc, argv );
        exit( 1 );
    }
    // Parse command line arguments
    int n = atoi( argv[ 1 ] );

    struct BigNumber fib;
    initBigNumber( &fib );
    bigFib( &fib, n );
    char buf[1000];

    bigNumberToString( &fib, buf, sizeof( buf ) );
    printf( "FIB %d : %s\n", n, buf );
}

