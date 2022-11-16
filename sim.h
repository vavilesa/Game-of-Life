/**
 * Game of Life
 * 
 * Game has an initial number of cells. At each generation:
 *
 * A live cell remains live if it has 2 neighbors. And dies
 * if it has 0 or 1 neighbors (loneliness), or more than 4 (overpopulation).
 * 
 * An empty space or dead cell becomes a live cell if it has 3 neighbors.
 *
 *
 */
#ifndef _SIM_H
#define _SIM_H
#include "board.h"

// simulation loop
extern void simLoop(boards_t *self, unsigned int steps); 

#endif
