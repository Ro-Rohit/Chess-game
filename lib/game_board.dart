import 'package:chess/dead_piece.dart';
import 'package:chess/helpers/chess_move.dart';
import 'helpers/last_dialog.dart';
import 'package:chess/icon_button.dart';
import 'package:flutter/material.dart';
import './square.dart';
import './piece.dart';
import 'app_colors.dart';
import 'helpers/initial_arrangement.dart';
import 'helpers/show_chess_option.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  List<List<int>> validMoves = [];
  late List<List<ChessPiece?>> board ;
   ChessPiece? selectedPiece;
   ChessPiece? substitutedPiece;
   bool isWhiteTurn = true;

  int selectedRow = -1;
  int selectedCol = -1;

  List<ChessPiece?> blackPieceTaken = [];
  List<ChessPiece?> whitePieceTaken = [];

  List<List<int>> undoList = [];
  List<List<int>>  redoList = [];
  List<List> undoRedoData = [];
  var undoRedoSteps = 0;

  //initial king position
   List<int>  blackKingPosition = [7, 4];
   List<int>  whiteKingPosition = [0, 4];
   bool checkStatus = false;

   bool isCheckMate(bool isWhiteKing){
     //if is king not under attack
     if(!isKingInCheck(isWhiteKing, whiteKingPosition, blackKingPosition, board)){
       return false;
     }

     for(int i=0; i<8; i++){
       for(int j = 0; j<8; j++){
         //if board  doesn't have piece or having different  type piece
         if(board[i][j] ==null || board[i][j]!.isWhite != isWhiteKing){
           continue;
         }

         //calculate move for same type  pieces
         List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j],
             true, board, whiteKingPosition, blackKingPosition);


         if(pieceValidMoves.isNotEmpty){
           return false;
         }
       }
     }

     return true;
   }

   void pieceSelected(int row, int col){
    //condition to check is white turn or black turn and on selected tiles have their own chess piece or not

     if(
    (
        isWhiteTurn &&
            ( (selectedPiece !=null) || (selectedPiece==null && ( board[row][col]!=null && board[row][col]!.isWhite) ))
    ) || (
        !isWhiteTurn &&
            ((selectedPiece !=null) ||(selectedPiece==null && (  board[row][col] !=null && !board[row][col]!.isWhite)))
        )
    ){
      // if user just select piece to view possible moves
      if (board[row][col] != null && selectedPiece == null) {
        setState(() {
          selectedPiece = board[row][col];
          selectedCol = col;
          selectedRow = row;
          validMoves = calculateRealValidMoves(
              selectedRow,
              selectedCol,
              selectedPiece,
              true, board,
              whiteKingPosition, blackKingPosition);
        });

      }

      // user moves piece from valid moves
      else if (selectedPiece != null && validMoves.any((pos) => pos[0] == row && pos[1] == col)  )
      {movePiece(row, col);}


      //if user selected a piece and now  they select again a new piece of same type
      else if ( selectedPiece !=null &&  board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        setState(() {
          selectedPiece = board[row][col];
          selectedCol = col;
          selectedRow = row;
          validMoves = calculateRealValidMoves(
              selectedRow,
              selectedCol,
              selectedPiece,
              true, board,
              whiteKingPosition, blackKingPosition);
        });
      }


      else {
        setState(() {
          selectedPiece = null;
          selectedRow = -1;
          selectedCol = -1;
          validMoves = [];
        });
      }
    }
  }

  Future<void> movePiece(int newRow, int newCol) async{


    //update king position if piece is king
    if(selectedPiece!.type == PieceType.king){
      if(selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      }else{
        blackKingPosition = [newRow, newCol];
      }
    }



    // storing initial and final position of pieces in undo & redo list
    if(undoList.length > undoRedoSteps){
      undoList[undoRedoSteps] = [selectedRow, selectedCol];
      redoList[undoRedoSteps] = [newRow, newCol];
      undoList.removeRange(undoRedoSteps+1, undoList.length);
      redoList.removeRange(undoRedoSteps+1, redoList.length);

    }else{
      undoList.add([selectedRow, selectedCol]);
      redoList.add([newRow, newCol]);
    }

    //piece on target position
    ChessPiece? capturedPiece = board[newRow][newCol];


    //finally change position of pieces
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;


    //if piece is pawn and  reached to the opposite end of board
    if(selectedPiece!.type == PieceType.pawn ){
      if(selectedPiece!.isWhite && newRow== 7 ){
        await showAnimatedDialog(
            content:  ShowChessOption(
              isWhite: true,
              substitutePiece: (ChessPiece newPiece){
                substitutedPiece = newPiece;
                setState(() { board[newRow][newCol] = newPiece; });

              },
            ));
      }else if(!selectedPiece!.isWhite && newRow ==0){
        await showAnimatedDialog(
            content:  ShowChessOption(
              isWhite: false,
              substitutePiece: (ChessPiece newPiece){
                substitutedPiece  =  ChessPiece(type: newPiece.type, imgPath: newPiece.imgPath, isWhite: false);
                setState(() {board[newRow][newCol] = substitutedPiece;});
              },));
      }
    }
    else{
      substitutedPiece = null;
    }


    
    //condition for piece to be died
    if(capturedPiece !=null){
      addDataToHisToryList(capturedPiece, whiteKingPosition, blackKingPosition,selectedPiece, substitutedPiece);

      if(capturedPiece.isWhite){
        whitePieceTaken.add(capturedPiece);
      }
      else{
        blackPieceTaken.add(capturedPiece);
      }
    }else{
      addDataToHisToryList(0, whiteKingPosition, blackKingPosition, selectedPiece, substitutedPiece);
    }


    setState(() {
      selectedRow =-1;
      selectedCol = -1;
      validMoves = [];
      selectedPiece = null;
      isWhiteTurn = !isWhiteTurn;
    });


    //check mate?
    if(isCheckMate(isWhiteTurn)){
        await showAnimatedDialog(
        content : PlayAgainDialog(reset: (){resetGame();}, isWhite: !isWhiteTurn)
    );

    }



    //set steps
    undoRedoSteps = undoList.length;

    // see if king are under attack
    if(isKingInCheck(isWhiteTurn, whiteKingPosition, blackKingPosition, board)){
      checkStatus = true;
    }else{
      checkStatus  =false;
    }

  }



  void resetGame(){
    setState(() {
      board = arrangeToInitial();
      selectedCol = -1;
      selectedRow -1;
      selectedPiece = null;
      validMoves = [];
      blackPieceTaken = [];
      whitePieceTaken= [];
      isWhiteTurn = true;
      checkStatus= false;
      undoRedoSteps = 0;
      undoList = [];
      redoList = [];
    });
  }

  //-----back to past and future ---

  void addDataToHisToryList(targetPiece, whiteKingPosition, blackKingPosition, currentPiece, substitutedPiece){

    if(undoRedoData.length  > undoRedoSteps){
      undoRedoData[undoRedoSteps]=[targetPiece, whiteKingPosition, blackKingPosition, currentPiece, substitutedPiece];
      undoRedoData.removeRange(undoRedoSteps+1, undoRedoData.length);
    }else{
      undoRedoData.add([targetPiece, whiteKingPosition, blackKingPosition, currentPiece, substitutedPiece]);
    }
  }



  void undoMove(){
    if(undoRedoSteps >0){
      List<int> pos2 = redoList[undoRedoSteps-1];
      List<int> pos1 = undoList[undoRedoSteps-1];
      var diedPiece = undoRedoData[undoRedoSteps-1][0];
      var curWhiteKingPos = undoRedoSteps !=1 ?undoRedoData[undoRedoSteps-2][1] : whiteKingPosition;
      var curBlackKingPos = undoRedoSteps != 1? undoRedoData[undoRedoSteps-2][2] : blackKingPosition;


      //make Piece alive again
      if(diedPiece !=0){
        diedPiece!.isWhite ==true ? whitePieceTaken.removeLast() : blackPieceTaken.removeLast();
      }

      // var oldPiece = board[pos2[0]][pos2[1]];
      var oldPiece = undoRedoData[undoRedoSteps-1][3];
      setState(() {
        board[pos2[0]][pos2[1]] = diedPiece ==0? null : diedPiece;
        board[pos1[0]][pos1[1]] = oldPiece;
        isWhiteTurn = !isWhiteTurn;
        checkStatus = isKingInCheck(isWhiteTurn, curWhiteKingPos, curBlackKingPos, board);
      });
      undoRedoSteps--;
    }

  }

  void redoMove(){
    if(undoList.length >undoRedoSteps) {
      undoRedoSteps++;
      undoRedoSteps ==0 ? undoRedoSteps=1: undoRedoSteps;

      List<int> currPos = undoList[undoRedoSteps - 1];
      List<int> nextPos = redoList[undoRedoSteps-1];

      //position at the time
      var curWhiteKingPos = undoRedoData[undoRedoSteps-1][1];
      var curBlackKingPos = undoRedoData[undoRedoSteps-1][2];

      //make died again
      var diedPiece = undoRedoData[undoRedoSteps-1][0];
      if(diedPiece != 0){
        diedPiece!.isWhite ? whitePieceTaken.add(diedPiece) : blackPieceTaken.add(diedPiece);
      }

      // var currPiece = board[currPos[0]][currPos[1]];
      var currPiece = undoRedoData[undoRedoSteps-1][4] ?? undoRedoData[undoRedoSteps-1][3];
      setState(() {
        board[currPos[0]][currPos[1]] = null;
        board[nextPos[0]][nextPos[1]] = currPiece;
        isWhiteTurn = !isWhiteTurn;
        checkStatus = isKingInCheck(isWhiteTurn, curWhiteKingPos, curBlackKingPos, board);
      });
    }
  }


  // dialog builder
  Future<void> showAnimatedDialog({Widget? content}) async{
    await showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: content,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    board = arrangeToInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [

          //black died pieces
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: blackPieceTaken.length,
                  gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, mainAxisSpacing: 2, crossAxisSpacing: 2),
                  itemBuilder: (_, index){
                    return RotatedBox(
                      quarterTurns: -2,
                      child: DeadPiece(
                        onTap:(){},
                        imgPath: blackPieceTaken[index]!.imgPath,
                        isWhite: blackPieceTaken[index]!.isWhite),
                    );
                  })
          ),

          //black check
          Positioned(
            height: 20,
            top: 150,
            left: MediaQuery.of(context).size.width/2.5,
            child: Text(checkStatus && !isWhiteTurn ? "CHECK!" : '',
              style: TextStyle(color: AppColors.tileColor1),),
          ),

          // undo Redo buttons
          Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height/1.3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButtonWidget(icon: Icons.restart_alt, onTap: (){resetGame();}),
                  IconButtonWidget(icon: Icons.u_turn_left_outlined, onTap: (){undoMove();}),
                  IconButtonWidget(icon: Icons.u_turn_right_rounded, onTap: (){redoMove();}),
                ],
              )),


          //Game Board
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height/4,

            child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8 * 8,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, idx){
                    //row, col = 0,0  0,1   0,2
                    int row = idx ~/ 8;
                    int col = idx % 8;


                    bool isPieceSelected = selectedRow ==row && selectedCol ==col;


                    // to show valid moves in a particular tiles for a selected piece
                    bool isValidMove = false;
                    for(var pos in validMoves){
                      if(pos[0] == row && pos[1] ==col){
                        isValidMove =true;
                      }
                    }

                    return SquareTile(
                        isTileWhite: isWhite(idx),
                        chessPiece: board[row][col],
                        onTap: () => pieceSelected(row, col),
                        isSelected: isPieceSelected,
                        isValidMove: isValidMove,
                    );

                  }),
          ),

          // white check
          Positioned(
            right: MediaQuery.of(context).size.width/2.2,
            top: MediaQuery.of(context).size.height/1.15,
            height: 20,
            child: RotatedBox(
                quarterTurns: -2,
                child: Text(checkStatus && isWhiteTurn ? "CHECK!" : '',
                  style: TextStyle(color: AppColors.tileColor1),)),
          ),


          // white died pieces
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: whitePieceTaken.length,
                  gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, mainAxisSpacing: 2, crossAxisSpacing: 2),
                  itemBuilder: (_, index){
                    return DeadPiece(
                      onTap: (){},
                      imgPath: whitePieceTaken[index]!.imgPath,
                      isWhite: whitePieceTaken[index]!.isWhite
                    );
                  })
          ),
        ],
      ),
    );
  }
}
