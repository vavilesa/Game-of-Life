/**
 * Game of Life. 
 *
 * Board Managment.
 *
 *
 *
 */
#include "cse30life.h"
#include "board.h"

 /**
  * create a new board
  *
  * - malloc a boards structure
  * - set the generation to 0
  * - open the file (if it doesn't exist, return a NULL pointer
  * - read the first line which is the number of rows
  * - read the second line which is the number of cols
  * - set the # of rows and # of cols in the boards structure
  * - malloc bufferA and bufferB
  * - Set currentBuffer and nextBuffer
  * - clear both board buffers
  * - read the file until done.  each row contains a row and a columns separted by
  *   white space
  *     for each line, set the cell in the current buffer
  * - close the file
  * - return the boards pointer if successfull or NULL ptr otherwise
  */
boards_t* createBoard(char* initFileName) {

	boards_t* board = malloc(sizeof(boards_t));

	// Attempt to open file to intialize board
	FILE* fp;
	if ((fp = fopen(initFileName, "r")) == NULL) {
		return NULL;
	}

	// number of rows and columns
	int numRows; 
	fscanf(fp, "%d", &numRows);
	board->numRows = numRows;

	int numCols;
	fscanf(fp, "%d", &numCols);
	board->numCols = numCols;

	// memory allocation for buffers
	board->bufferA = malloc(sizeof(belem) * numRows * numCols);
	board->bufferB = malloc(sizeof(belem) * numRows * numCols);
	clearBoards(board);

	// set current and next buffer to existing buffer
	board->currentBuffer = board->bufferA;
	board->nextBuffer = board->bufferB;

	// Populate initial cells
	int row;
	int col;
	while (fscanf(fp, "%d %d", &row, &col) > 0) {

		int index = getIndex(numCols, row, col);
		board->currentBuffer[index] = 1;
	}

	//set generation to 0
	board->gen = 0;

	fclose(fp);
	return board;
}



/**
 * delete a board
 */
void deleteBoard(boards_t** bptrPtr) {
	
	// free buffers and board struct
	free((*bptrPtr)->bufferA);
	free((*bptrPtr)->bufferB);
	free(*bptrPtr);

	*bptrPtr = NULL;
}

/**
 * set board elements in both buffers to initial value
 */
void clearBoards(boards_t* self) {

	belem* cellsA = self->bufferA;
	belem* cellsB = self->bufferB;

	int rows = self->numRows;
	int cols = self->numCols;

	for (int i = 0; i < (rows * cols); i++) {
		*(cellsA + i) = 0;
		*(cellsB + i) = 0;
	}
}

/**
 * swap the current and next buffers
 */
void swapBuffers(boards_t* self) {
	
	belem* temp = (self->currentBuffer);
	self->currentBuffer = self->nextBuffer;
	self->nextBuffer = temp;
}


/**
 * cell's coordinates to index
 */
size_t getIndex(size_t numCols, size_t row, size_t col) {
	return row * numCols + col;
}

