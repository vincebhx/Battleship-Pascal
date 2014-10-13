program Battleship;

type 
	Tile = record
		posX : 0..9;
        posY : 'A'..'J';
        state : char;
    end;
    Grid = array[0..9, 'A'..'J'] of Tile;

    BoatCoord = array[1..5] of Tile;
    Boat = record
        coord : BoatCoord;
        size : 2..5;
        sunk : boolean;
    end;
    BoatGrid = array[1..5] of Boat;

var 
	mainGridPlayer1, mainGridPlayer2, targetGridP1, targetGridP2 : Grid;
    boatsPlayer1, boatsPlayer2 : BoatGrid;
    isOpponentDown : boolean;
    i,j : integer;

//Grid display procedure
procedure display(var gridDisplay : Grid);
var i : integer;
    c : char;
begin
	writeln;
    writeln('   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |');
    writeln('--------------------------------------------');
	
    for c := 'A' to 'J' do
    begin
		write(' ', c, ' ');
		for i := 0 to 9 do
			write('| ',gridDisplay[i,c].state,' ');
			writeln('|');
			writeln('--------------------------------------------');
    end;
	
    writeln;
end;

//Boat placement procedure
procedure placeBoats(var localGrid : Grid; var boats : BoatGrid; boatSize, boatAddress : integer);
var strMain : string;
	pos1, pos2 : Tile;
    i, j, tmpInt : integer;
    c, tmpChr : char;
    isBoatOverriding : boolean;

begin
	boats[boatAddress].size := boatSize;
    boats[boatAddress].sunk := false;
    for j := 1 to boatSize do
		boats[boatAddress].coord[j].state := 'O';
		
    repeat
		isBoatOverriding := false;

		//Coordinates reading and boat size checking
        repeat
			write('Place a boat with a length of ', boatSize, ' tiles (Indicate 2 coordinates, from A0 to J9, separated with a space) : ');
            readln(strMain); // Example of input string : 'A1 A3'
            pos1.posY := strMain[1];
            pos1.posX := ord(strMain[2])-48;
            pos2.posY := strMain[4];
            pos2.posX := ord(strMain[5])-48;
        until ((pos1.posY = pos2.posY) and (abs(pos2.posX - pos1.posX) = boatSize-1))
			or ((pos1.posX = pos2.posX) and (abs(ord(pos2.posY) - ord(pos1.posY)) = boatSize-1));

		//Algorithm for lines (working with posX integers);
        if pos1.posY = pos2.posY then
		begin
			if pos1.posX > pos2.posX then
            begin
				tmpInt := pos1.posX;
                pos1.posX := pos2.posX;
                pos2.posX := tmpInt;
            end;

			//Security against overriding boats
            for i := pos1.posX to pos2.posX do 
				if localGrid[i, pos1.posY].state = 'O' then
				isBoatOverriding := true;

			//Placement of the boats when there is no override
            if isBoatOverriding = false then
			begin
				j := 1;
				for i := pos1.posX to pos2.posX do
                begin
                    localGrid[i,pos1.posY].state := 'O';
                    boats[boatAddress].coord[j].posX := i;
                    boats[boatAddress].coord[j].posY := pos1.posY;
                    j := j+1;
                end;
            end;
        end;

		//Same algorithm for columns (working with posY chars)
        if pos1.posX = pos2.posX then
        begin
            if pos1.posY > pos2.posY then
            begin
                tmpChr := pos1.posY;
                pos1.posY := pos2.posY;
                pos2.posY := tmpChr;
            end;
			
            for c := pos1.posY to pos2.posY do
				if localGrid[pos1.posX, c].state = 'O' then
				isBoatOverriding := true;
				
            if isBoatOverriding = false then
            begin
                j := 1;
                for c := pos1.posY to pos2.posY do
                begin
                    localGrid[pos1.posX, c].state := 'O';
                    boats[BoatAddress].coord[j].posX := pos1.posX;
                    boats[BoatAddress].coord[j].posY := c;
                    j := j+1;
                end;
            end;
        end;

        if isBoatOverriding = true then
		writeln('Boats are overriding. Please enter again the previous one.')
        else
        begin
            writeln('Boat successfully registered !');
            display(localGrid);
            writeln;
        end;

    until isBoatOverriding = false;
end;

// Grid initialisation procedure
procedure setGrid(var localGrid : Grid; var boats : BoatGrid);
var confirm, c : char;
	i : integer;
begin
    repeat
        placeBoats(localGrid, boats, 2, 1);
        placeBoats(localGrid, boats, 3, 2);
        placeBoats(localGrid, boats, 3, 3);
        placeBoats(localGrid, boats, 4, 4);
        placeBoats(localGrid, boats, 5, 5);

        repeat
			write('Do you want to confirm and keep this grid ? y/n : ');
            readln(confirm);
            writeln;
        until (confirm = 'n') or (confirm = 'N') or (confirm = 'y') or (confirm = 'Y');
		
		//Reset of the grid if 'n' is selected
		if (confirm = 'n' )or (confirm = 'N') then
			for i := 0 to 9 do
				for c := 'A' to 'J' do
				localGrid[i, c].state := ' ';
				
	until (confirm = 'y') or (confirm = 'Y');	  
end;

// Main game procedure (Player turn)
procedure turn(persGrid : Grid; var targetGrid, displayGrid : Grid; var boats : BoatGrid; playerId : integer; var isOpponentDown : boolean);
var strPos, strReturn : string;
    targetPos : Tile;
    isBoatHit, isBoatSunk : boolean;
    i, j : integer;
begin
	//Variable initialisation
	isOpponentDown := true;
    isBoatHit := false;
    strReturn := 'Miss !';
    i := 0;
	
	//Turn beginning display (Player ID, player's grid, opponent's hidden grid)
    writeln;
    writeln('Player ', playerId, ', it is your turn');
    writeln('Your grid :');
    display(persGrid);
    writeln;
    writeln('Your opponent''s grid :');
    display(displayGrid);
	
	//Target input
	repeat
		writeln;
		write('Player ', playerId,', enter a target coordinate (from A0 to J9) : ');
		readln(strPos);
		targetPos.posY := strPos[1];
		targetPos.posX := ord(strPos[2])-48;
	until (0 <= targetPos.posX) and (targetPos.posX <= 9) and ('A' <= targetPos.posY) and (targetPos.posY <= 'J');
	
	//Main algorithm : Test of the opponent's boat grid;
	//If the boat is sunk, the algorithm directly goes to the next boat
	repeat
		i := i+1;
		if boats[i].sunk = false then
		begin
			isBoatSunk := true;
			
			//For each boat, the program searches a coordinate corresponding to the target position.
			//If there's one, the current boat is declared hit.
			//If all the boat's coordinates are hit, the boat is declared sunk.
            for j := 1 to boats[i].size do
            begin
                if (targetPos.posX = boats[i].coord[j].posX) and (targetPos.posY = boats[i].coord[j].posY) then
                begin
                    boats[i].coord[j].state := 'X';
                    targetGrid[targetPos.posX, targetPos.posY].state := 'X';
                    displayGrid[targetPos.posX, targetPos.posY].state := 'X';
                    isBoatHit := true;
                end;
				
                if boats[i].coord[j].state <> 'X' then
				isBoatSunk := false;
            end;
			
			//Affectation of a string to display the result
            if isBoatSunk = true then
            begin
                strReturn := 'Sunk !';
                boats[i].sunk := true;
            end
            else 
				if isBoatHit = true then
				strReturn := 'Hit !'
                else strReturn := 'Miss !';
		end;
    until (i = 5) or (isBoatHit = true);
	
	//Indication of the missed position on the displayed grid
	if strReturn = 'Miss !' then
		displayGrid[targetPos.posX, targetPos.posY].state := '~';
	
	//Test of the game's end : the games continues until all the boats are sunk
	for i := 1 to 5 do
		if boats[i].sunk = false then
		isOpponentDown := false;

	//End of turn display
	isBoatSunk := false;
    writeln;
    writeln(strReturn);
    writeln;

    if isOpponentDown = true then
	//End of game display
    begin
        writeln;
        writeln('End of game !');
        writeln('The winner is : Player ', playerId);
        readln;
        writeln;
        writeln('Player 1''s grid :');
        display(mainGridPlayer1);
        readln;
        writeln;
        writeln('Player 2''s grid :');
        display(mainGridPlayer2);
    end
    else 
	//Display of the opponent's hidden grid (End of turn only)
	begin
        display(displayGrid);
        readln;
    end;
end;

begin
	writeln('-----------------BATTLESHIP-----------------');
    writeln;

	//Grid input for Player 1
    writeln('Player 1, place your boats');
    display(mainGridPlayer1);
	setGrid(mainGridPlayer1, boatsPlayer1);

    for i := 1 to 30 do
	writeln;
	
	//Grid input for Player 2
    writeln('Player 2, place your boats');
    display(mainGridPlayer2);
    setGrid(mainGridPlayer2, boatsPlayer2);

	writeln;
	writeln('Let the battle begin !');

	//Main execution
	repeat
		turn(mainGridPlayer1, mainGridPlayer2, targetGridP2, boatsPlayer2, 1, isOpponentDown);
		if isOpponentDown = false then
        turn(mainGridPlayer2, mainGridPlayer1, targetGridP1, boatsPlayer1, 2, isOpponentDown);
	until isOpponentDown = true;

	readln;
end.