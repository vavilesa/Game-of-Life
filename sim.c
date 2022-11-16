/**
 * Game of Life.
 *
 * Simulate successive generations. 
 *
 */
#include "sim.h"

#define CIMP
extern void asm_doRow(belem*, belem*, size_t, size_t, size_t);

/**
 * gets x mod N (works for negative numbers as well! Use this instead of %)
 */
size_t getModVal(int x, size_t N) {
    size_t adj = x / N;

    return((x + adj * N) % N);
}

/**
 * process one row of the board
 */
static void doRow(belem* dest, belem* src, size_t row, size_t rows, size_t cols) {

    // Iterates over each cell in the column
    for (size_t col = 0; col < cols; col++) {

        // current row and col of the cell in 2D
        int currRow = row;
        int currCol = col;

        // total number of alive neighbors
        int neighbors = 0;

        // searches all 8 possible neighbors, can get out bounds but
        // taking the modulus accounts for a 2D array wraping around
        for (int i = 0; i < 8; i++) {

            currRow = row;
            currCol = col;

            switch (i) {
                case 0: //right
                    currCol += 1;
                    break;

                case 1: //left
                    currCol -= 1;
                    break;

                case 2: // up
                    currRow -= 1;
                    break;

                case 3: // up right
                    currRow -= 1;
                    currCol += 1;
                    break;

                case 4: //up left
                    currRow -= 1;
                    currCol -= 1;
                    break;

                case 5: //down
                    currRow += 1;
                    break;

                case 6: // down right
                    currRow += 1;
                    currCol += 1;
                    break;

                case 7: //down left
                    currRow += 1;
                    currCol -= 1;
                    break;
            }

            // convert 2D indices to 1D index of neighbor cell
            currRow = getModVal(currRow, rows);
            currCol = getModVal(currCol, cols);
            int index = currRow * cols + currCol;

            // check if neighbor is alive
            if (*(src + index) == 1) {
                neighbors++;
            }
            
        }


        // 2D to 1D of current cell
        int currIndex = row * cols + col;
        belem* newCell = dest + currIndex;

        // dies 0,1 = loneliness, 4 = overpopulation
        if (neighbors <= 1 || neighbors >= 4) {
           *newCell = 0;
        }

        // dead cell with 3 neighbors revives, alive cell stays alive
        else if (neighbors == 3) {
            *newCell = 1;
        }

        // alive cells with 2 neighbors remain alive
        else if (*(src + currIndex) == 1) {
            *newCell = 1;

        }

        // dead cell stays dead
        else {
            *newCell = 0;
        } 
        
    }

}


/**
 * perform a simulation for "steps" generations
 *
 */
void simLoop(boards_t* self, unsigned int steps) {

    // repeat process for the specified number of steps for each row 
    for (unsigned int i = 0; i < steps; i++) {

        for (size_t row = 0; row < self->numRows; row++) {
            doRow(self->nextBuffer, self->currentBuffer, row, self->numRows, self->numCols);
        }

        // swap current and next buffer, increase generation count
        swapBuffers(self);
        (self->gen)++;

    }

}