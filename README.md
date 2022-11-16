# Game of Life

Game has an initial number of cells (provided in a text file) in a 2D board. At each generation:
- A live cell remains live if it has 2 neighbors.
-  A live cell dies if it has 0 or 1 neighbors (loneliness), or more than 4 (overpopulation). 
- And empty space or dead cell becomes a live cell if it has 3 neighbors.
