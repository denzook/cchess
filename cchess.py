from abc import ABC, abstractmethod

#from abc import ABC, abstractmethod
import sys
import copy

class Game:
    def __init__(self):
        self.pieces = []
        self.removed = []
        
        # { piece:, move: } 
        # move = (0,0) means consumed
        self.history = [] 
        
        # gen/king location, index 0 = RED, index 1 is BLACK
        self.gens = []

    def reset(self):
        self.pieces.clear()
        self.history.clear()
        self.removed.clear()
        self.gens.clear()
        
        self.pieces.append(chariot(self,piece.RED,(0,0)))
        self.pieces.append(knight(self,piece.RED,(1,0)))
        self.pieces.append(xiang(self,piece.RED,(2,0)))
        self.pieces.append(guard(self,piece.RED,(3,0)))
        self.pieces.append(gen(self,piece.RED,(4,0)))
        self.pieces.append(guard(self,piece.RED,(5,0)))
        self.pieces.append(xiang(self,piece.RED,(6,0)))
        self.pieces.append(knight(self,piece.RED,(7,0)))
        self.pieces.append(chariot(self,piece.RED,(8,0)))
        
        self.pieces.append(pawn(self,piece.RED,(0,3)))
        self.pieces.append(pawn(self,piece.RED,(2,3)))
        self.pieces.append(pawn(self,piece.RED,(4,3)))
        self.pieces.append(pawn(self,piece.RED,(6,3)))
        self.pieces.append(pawn(self,piece.RED,(8,3)))
        self.pieces.append(cannon(self,piece.RED,(1,2)))
        self.pieces.append(cannon(self,piece.RED,(8-1,2)))
    
        self.pieces.append(chariot(self,piece.BLACK,(0,9-0)))
        self.pieces.append(knight(self,piece.BLACK,(1,9-0)))
        self.pieces.append(xiang(self,piece.BLACK,(2,9-0)))
        self.pieces.append(guard(self,piece.BLACK,(3,9-0)))
        self.pieces.append(gen(self,piece.BLACK,(4,9-0)))
        self.pieces.append(guard(self,piece.BLACK,(5,9-0)))
        self.pieces.append(xiang(self,piece.BLACK,(6,9-0)))
        self.pieces.append(knight(self,piece.BLACK,(7,9-0)))
        self.pieces.append(chariot(self,piece.BLACK,(8,9-0)))
        
        self.pieces.append(pawn(self,piece.BLACK,(0,9-3)))
        self.pieces.append(pawn(self,piece.BLACK,(2,9-3)))
        self.pieces.append(pawn(self,piece.BLACK,(4,9-3)))
        self.pieces.append(pawn(self,piece.BLACK,(6,9-3)))
        self.pieces.append(pawn(self,piece.BLACK,(8,9-3)))
        self.pieces.append(cannon(self,piece.BLACK,(1,9-2)))
        self.pieces.append(cannon(self,piece.BLACK,(8-1,9-2)))
        
        for a in range(2): self.gens.append(None)
        for a in self.pieces:
            if(a.type == piece.GEN): self.gens[0 if(a.side==piece.RED) else 1] = a
            if(None not in self.gens): break
        
    def hasPiece(self, pos):
        for a in self.pieces:
            if(a.pos==pos): return a
        return None
    
    def killTheGen(self,side):
        if((gen:=self.gens[1 if(side==piece.RED) else 0]) != None):
            for a in self.pieces:
                if(a.side == side and not a.isMoveIllegal(a.toMove(gen.pos))): 
                    return a
        return None
    
    def removeGen(self,side):
        if(self.gens[side:=  (0 if (side==piece.RED) else 1)]):
            self.gens[side] = None
            
            
    def mate(self,side):
        pieces = [a for a in self.pieces if(a.side == side)]
        ok=[]
        altside = piece.RED if(side==piece.BLACK) else piece.BLACK
        while(len(pieces)>0):
            moves = pieces[-1].getAllMoves()
            while(len(moves)> 0):
                p = {'piece':pieces[-1],'move':moves[-1]}
                del moves[-1]
                pos=p['piece'].pos
                pos2=p['piece'].getMoveToPos(p['move'])
                
                if((r := self.hasPiece(pos2))!=None):
                    self.pieces.remove(r)
                p['piece'].pos = pos2
                if(self.killTheGen(altside) == None): ok.append(p)
                if(r): self.pieces.append(r)
                
                p['piece'].pos = pos
            del pieces[-1]
        return ok
                    
            
    def copypieces(self,game=None, allhistory=False):
        if(not game): game = Game()
        game.pieces.clear()
        game.removed.clear()
        game.history.clear()
        game.gens = [None,None]
        for a in self.pieces:
            if(a.gettype()==piece.PAWN): game.pieces.append(pawn(game,a.side,a.pos))
            elif(a.gettype()==piece.CANNON): game.pieces.append(cannon(game,a.side,a.pos))
            elif(a.gettype()==piece.CHARIOT): game.pieces.append(chariot(game,a.side,a.pos))
            elif(a.gettype()==piece.KNIGHT): game.pieces.append(knight(game,a.side,a.pos))
            elif(a.gettype()==piece.XIANG): game.pieces.append(xiang(game,a.side,a.pos))
            elif(a.gettype()==piece.GUARD): game.pieces.append(guard(game,a.side,a.pos))
            elif(a.gettype()==piece.GEN): 
                game.pieces.append(p:=gen(game,a.side,a.pos))
                game.gens[0 if(a.side==piece.RED) else 1] = p
        if(allhistory): game.history=self.copyHist(game)
            
        return game
    
    def copyHist(self, game=None):
        out=[]
        for aa in self.history:
            a = aa['piece']
            if(a.gettype()==piece.PAWN): out.append({'piece':pawn(game,a.side,a.pos),'move':aa['move']})
            elif(a.gettype()==piece.CANNON): out.append({'piece':cannon(game,a.side,a.pos),'move':aa['move']})
            elif(a.gettype()==piece.CHARIOT): out.append({'piece':chariot(game,a.side,a.pos),'move':aa['move']})
            elif(a.gettype()==piece.KNIGHT): out.append({'piece':knight(game,a.side,a.pos),'move':aa['move']})
            elif(a.gettype()==piece.XIANG): out.append({'piece':xiang(game,a.side,a.pos),'move':aa['move']})
            elif(a.gettype()==piece.GUARD): out.append({'piece':guard(game,a.side,a.pos),'move':aa['move']})
            elif(a.gettype()==piece.GEN):out.append({'piece':gen(game,a.side,a.pos),'move':aa['move']})
        return out
   
class piece(ABC):
    PAWN=1
    CANNON=2
    CHARIOT=3
    KNIGHT=4
    XIANG=5
    GUARD=6
    GEN=7
    RED=1
    BLACK=2

#move is vector (x,y), RED y positive go down, right, BLACK y go up, left
#pos is coordinate (x,y)
#board is 9x10, (0,0) is left-top
#red is placed at top.

    def isValidPos(pos):
        if(pos[0] < 0 or pos[0]>= 9): return False
        if(pos[1]< 0 or pos[1] >= 10): return False
        return True

    
    def getMoveToPos(self, move):
        return (self.pos[0]+(move[0] if(self.side==piece.RED) else -move[0]),
                self.pos[1]+(move[1] if(self.side==piece.RED) else -move[1]))
    
    def toMove(self, pos):
        p=(pos[0]-self.pos[0], pos[1]-self.pos[1])
        if(self.side==piece.RED): return p
        return (-p[0],-p[1])
        
    
    def hasCrossedHalf(self,pos=None):
        if(pos==None): pos=self.pos
        return (pos[1]>=5 and self.side == piece.RED) or \
               (pos[1]<5 and self.side == piece.BLACK)
               
    def isInside(self,pos=None):
        if(pos==None): pos=self.pos
        if(pos[0]<3 or pos[0]>5): return False
        if(self.side==piece.RED):
            if(pos[1]<0 or pos[1]>2): return False
        else:
            if(pos[1]<7 or pos[1]>9): return False
        return True
    
    @abstractmethod
    def getNextMove(self, move):
        return None
    
    def getCurrentPos(self):
        return self.pos
    
    def setPos(self, pos):
        self.pos=pos
    
    @abstractmethod
    def isMoveIllegal(self, move):
        if(move == None or move ==(0,0)): return True
        if(not piece.isValidPos(pos:=self.getMoveToPos(move)) or
           ((a:=self.game.hasPiece(pos)) != None and a.side == self.side) ):
            return True
        return False
    
    def getAllMoves(self):
        out=[]
        move=None
        while((move:= self.getNextMove(move)) != None):
          out.append(move)  
        return out
    
    def gettype(self):
        return self.type
    
    def __init__(self, game, type, side, pos):
        self.type = type
        self.side = side
        self.setPos(pos)
        self.ctx = None
        self.game = game
        pass

class pawn(piece):
    def getNextMove(self, move):
        while (True):
            if(move==None): move=(0,1)
            else:
                if(self.hasCrossedHalf()):
                    if(move==(0,1)): move=(1,0)
                    elif(move==(1,0)): move=(-1,0)
                    else: move=None
                else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        if(move[1]<0 or move[1]>1): return True
        if(self.hasCrossedHalf()):
            if (move[0]<-1 or move[0] > 1): return True
            elif(move[0]!= 0 and move[1] !=0): return True
        elif(move[0]!= 0): return True
        return False
    
    def __init__(self, game, side, pos):
        super().__init__(game, piece.PAWN, side, pos)

class chariot(piece):
    def getNextMove(self, move):
        invalid=False
        while (True):
            if(move==None): move=(0,1)
            elif(move[0]==0 and move[1]>=1):
                if(invalid): move=(1,0)
                else: move=(move[0],move[1] + 1)
            elif(move[1]==0 and move[0]>=1):
                if(invalid):  move=(0,-1)
                else: move=(move[0]+1,move[1])
            elif(move[0]==0 and move[1]<=-1):
                if(invalid):  move=(-1,0)
                else: move=(move[0],move[1]-1)
            elif(move[1]==0 and move[0]<=-1):
                if(invalid):  move=None
                else: move=(move[0]-1,move[1])
            else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
            invalid = True
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        if(move[1]!= 0 and move[0]!= 0): return True
        for a in  range(0,move[0],-1 if(move[0] < 0) else 1):
            if(a == 0): continue
            if(self.game.hasPiece(self.getMoveToPos((a,move[1])))): return True
        for a in  range(0,move[1],-1 if(move[1] < 0) else 1):
            if(a == 0): continue
            if(self.game.hasPiece(self.getMoveToPos((move[0],a)))): return True            
        
        return False
    
    def __init__(self, game, side, pos):
        super().__init__(game, piece.CHARIOT, side, pos)


class xiang(piece):
    def getNextMove(self, move):
        while (True):
            if(move==None): move=(2,2)
            elif(move == (2,2)): move=(2,-2)
            elif(move == (2,-2)): move=(-2,-2)
            elif(move == (-2,-2)): move=(-2,2)
            else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        
        if(move!=(2,2) and move!=(2,-2) and move!=(-2,-2) and move!=(-2,2)): 
            return True
        
        if(self.hasCrossedHalf(self.getMoveToPos(move))):
            return True
        
        for a in  range(1,2):
            pos=self.getMoveToPos((a if (move[0]>0) else -a,
                                  a if (move[1]>0) else -a))
            if(self.game.hasPiece(pos)): return True
        
        return False
    
    def __init__(self, game, side, pos):
        super().__init__(game, piece.XIANG, side, pos)


class cannon(piece):
    def getNextMove(self, move):
        invalid=False
        while (True):
            if(move==None): move=(0,1)
            elif(move[0]==0 and move[1]>=1):
                if(invalid): move=(1,0)
                else: move=(move[0],move[1] + 1)
            elif(move[1]==0 and move[0]>=1):
                if(invalid):  move=(0,-1)
                else: move=(move[0]+1,move[1])
            elif(move[0]==0 and move[1]<=-1):
                if(invalid):  move=(-1,0)
                else: move=(move[0],move[1]-1)
            elif(move[1]==0 and move[0]<=-1):
                if(invalid):  move=None
                else: move=(move[0]-1,move[1])
            else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
            invalid = not piece.isValidPos(self.getMoveToPos(move))
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        if(move[1]!= 0 and move[0]!= 0): return True
        pos=self.getMoveToPos(move)
        cnt=0
        for a in  range(0,move[0],-1 if(move[0] < 0) else 1):
            if(a==0): continue
            if(self.game.hasPiece(self.getMoveToPos((a,move[1]))) and (cnt:=cnt+1)>1): 
                return True
        for a in  range(0,move[1],-1 if(move[1] < 0) else 1):
            if(a==0): continue
            if(self.game.hasPiece(self.getMoveToPos((move[0],a))) and (cnt:=cnt+1)>1): 
                return True            
        
        a=self.game.hasPiece(pos)
        if(cnt == 0 and a): return True
        if(cnt > 0 and not a): return True
        
        return False

    def __init__(self, game, side, pos):
        super().__init__(game, piece.CANNON, side, pos)

        
class knight(piece):
    def getNextMove(self, move):
        while (True):
            if(move==None): move=(1,2)
            elif(move == (1,2)): move=(-1,2)
            
            elif(move == (-1,2)): move=(2,1)
            elif(move == (2,1)): move=(2,-1)
            
            elif(move == (2,-1)): move=(1,-2)
            elif(move == (1,-2)): move=(-1,-2)
            
            elif(move == (-1,-2)): move=(-2,1)
            elif(move == (-2,1)): move=(-2,-1)
            
            else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        if(move not in [(1,2),(-1,2),(2,1), (2,-1),
                        (1,-2),(-1,-2),(-2,1),(-2,-1)]):
            return True
        
        if(move[0]==2 and self.game.hasPiece(self.getMoveToPos((1,0)))): return True
        elif(move[0]==-2 and self.game.hasPiece(self.getMoveToPos((-1,0)))): return True
        elif(move[1]==2 and self.game.hasPiece(self.getMoveToPos((0,1)))): return True
        elif(move[1]==-2 and self.game.hasPiece(self.getMoveToPos((0,-1)))): return True
        
        return False        

    def __init__(self, game, side, pos):
        super().__init__(game, piece.KNIGHT, side, pos)

class guard(piece):
    def getNextMove(self, move):
        while (True):
            if(move==None): move=(1,1)
            elif(move == (1,1)): move=(1,-1)
            elif(move == (1,-1)): move=(-1,-1)
            elif(move == (-1,-1)): move=(-1,1)
            else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        if(move!=(1,1) and move!=(1,-1) and move!=(-1,-1) and move!=(-1,1)): 
            return True
        if(not self.isInside(self.getMoveToPos(move))):
            return True
        return False    

    def __init__(self, game, side, pos):
        super().__init__(game, piece.GUARD, side, pos)

class gen(piece):
    def getNextMove(self, move):
        while (True):
            if(move==None): 
                if((gen:=self.game.gens[1 if(self.side==piece.RED) else 0] ) != None):
                    move=self.toMove(gen.pos)
                else: move=(0,1)
            elif(move[1] > 1): move=(0,1)
            elif(move == (0,1)): move=(1,0)
            elif(move == (1,0)): move=(0,-1)
            elif(move == (0,-1)): move=(-1,0)
            else: move=None
            if(move==None): break
            if(not self.isMoveIllegal(move)): break
        return move
               
    def isMoveIllegal(self, move):
        if(super().isMoveIllegal(move)): return True
        pos=self.getMoveToPos(move)
        if((a:=self.game.hasPiece(pos)) != None and  a.gettype() == piece.GEN):
            if(move[0] != 0): return True
            for p in range(self.pos[1],pos[1],
                           1 if (pos[1]>self.pos[1]) else -1):
                if(p==self.pos[1]): continue
                if(self.game.hasPiece( ( pos[0],p))): return True
            return False
        
        if(move!=(0,1) and move!=(1,0) and move!=(0,-1) and move!=(-1,0)): 
            return True
        
        if(not self.isInside(pos)):
            return True
        
        return False

    def __init__(self, game, side, pos):
        super().__init__(game, piece.GEN, side, pos)

mainGame = Game()

# =====================================================================

from PyQt5.QtCore import QObject, QVariant, QPoint, QRect, QMetaObject, Qt
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtQuick import QQuickItem
import PyQt5.QtWidgets

#qApp = PyQt5.QtWidgets.QApplication(sys.argv)

# @QmlElement
class mObject(QObject):
    def __init__(self, engine, parent=None):
        super().__init__(parent)
        self.engine=engine
        self.root=engine.rootObjects()[0]
        
    @Slot()
    def reset(self):
        mainGame.reset()
        aiThread.quit()
        p=mainGame.pieces.copy()
        for a in self.root.getAllPieces().toVariant():
            aa=a.property("source").toString().split("/")[-1]
            for i in range(len(p)):
                if((aa.startswith("red-") and p[i].side==piece.RED) or
                   (aa.startswith("blk-") and p[i].side==piece.BLACK)):
                   if( (aa.endswith("-pawn.svg") and p[i].type ==piece.PAWN) or
                       (aa.endswith("-cannon.svg") and p[i].type ==piece.CANNON) or
                       (aa.endswith("-char.svg") and p[i].type ==piece.CHARIOT) or
                       (aa.endswith("-knight.svg") and p[i].type ==piece.KNIGHT) or
                       (aa.endswith("-xiang.svg") and p[i].type ==piece.XIANG) or
                       (aa.endswith("-guard.svg") and p[i].type ==piece.GUARD) or
                       (aa.endswith("-gen.svg") and p[i].type ==piece.GEN) ):
                       p[i].ctx = a
                       #self.parent().updatePos(a, QPoint(p[i].pos[0],p[i].pos[1]), True, True)
                       a.setProperty("posx", p[i].pos[0]*100)
                       a.setProperty("posy", p[i].pos[1]*100)
                       a.setProperty("visible", True)
                       a.setProperty("opacity", 1.0)
                       del p[i]
                       break
    @Slot(QQuickItem,result=list)
    def getValidPlace(self, item):
        out = []
        for a in mainGame.pieces:
            if(a.ctx == item):
                for b in  a.getAllMoves():
                    b = a.getMoveToPos(b)
                    out.append(QPoint(b[0]*100, b[1]*100))
                break
        return out
    
    @Slot(QPoint,QQuickItem,QQuickItem,bool,result=int)
    def updatePos(self, pos, item, remove=None, forundo=False):
        for a in mainGame.pieces:
            if(a.ctx == item):
                #pos=(item.property("posx"),item.property("posy"))
                pos = (int(pos.x()/100),int(pos.y()/100))
                if(not forundo): mainGame.history.append({'piece':copy.copy(a), 'move': a.toMove(pos) })
                a.pos = pos
                self.parent().setChecked (mainGame.killTheGen(a.side) != None)
                break   
            
        if(remove and not forundo):
            for i in range(len(mainGame.pieces)):
                a = mainGame.pieces[i]
                if(a.ctx == remove):
                    if(a.gettype()==piece.GEN): mainGame.removeGen(a.side)
                    mainGame.history.append({'piece': copy.copy(a), 'move':(0,0)})
                    mainGame.removed.append(a)
                    del mainGame.pieces[i]   
                    break
        return len(mainGame.history)-len(mainGame.removed)
                
    @Slot(int,result=QQuickItem)
    def killTheGen(self, side):
        if((a := mainGame.killTheGen(side)) != None): return a.ctx;
        return None
        #     gen=gens[1 if(side==piece.RED) else 0]
        #     return { 'item':a.ctx, 'pos': QPoint(gen.pos[0], gen.pos[1])}
        # return None
    
    @Slot(int,result=int)
    def undo(self, side):
        done=False
        while(not done and len(mainGame.history)>0): 
            if(mainGame.history[-1]['move'] == (0,0) and len(mainGame.removed)>0):
                mainGame.pieces.append(a:=mainGame.removed[-1])
                del mainGame.removed[-1]
                if(a.gettype()==piece.GEN): mainGame.gens[0 if(a.side==1) else 1] = a
            else: 
                a = mainGame.history[-1]['piece']
                if(a.side == side):  done = True
            self.parent().updatePos(a.ctx, QPoint(a.pos[0]*100,a.pos[1]*100), True)
            if(done and (mainGame.killTheGen(side) or
                mainGame.mate(piece.BLACK if(side==piece.RED) else piece.RED) == [])):
                done = False
            
            #print("move - " + str(a.pos))
            del mainGame.history[-1]
            
        # check if there's checked
        for i in range(len(mainGame.history)-1,-1,-1):
            if(mainGame.history[i]['move'] == (0,0)): continue
            a = mainGame.history[i]['piece']
            pos=a.getMoveToPos(mainGame.history[i]['move'])
            self.parent().updatePos(a.ctx, QPoint(pos[0]*100,pos[1]*100), True)
            #print("checked - " + str(pos))
            break
            
        return len(mainGame.history)-len(mainGame.removed)
    
    @Slot(int)
    def useAI(self, side):
        aiThread.start(mainGame, side, 5, 
                       lambda: QMetaObject.invokeMethod (self, "doneAI", Qt.QueuedConnection),
                       8)
    
    @Slot()
    def doneAI(self):
        a = aiThread.move['piece']
        if((aa := mainGame.hasPiece(a.pos)) != None):
            pos=aa.getMoveToPos(aiThread.move['move'])
            self.parent().doneAI(aa.ctx, QPoint(pos[0]*100, pos[1]*100))

try:  
    if(qApp != None): pass
except NameError: qApp = PyQt5.QtGui.QGuiApplication(sys.argv)

def run(bRun=None):
    engine = QQmlApplicationEngine()
    bridge = None
    #engine.rootContext().setContextProperty("mObject", mObject())
    engine.load("cchess.qml")
    
    if(engine.rootObjects()):
        obj=engine.rootObjects()[0]
        obj.setProperty("bridge", (bridge:=mObject(engine, obj)))
        #bridge.reset()
    
    if(bRun):
        ret=qApp.exec()
        del engine
        return ret
        
    return engine
    #if engine.rootObjects(): qApp.exec_()
    #del engine

#=======================================

import threading
import time
import random


class AIThread:
    def __init__(self):
        self.game = None
        
        self.elapse = 0
        self.expire=0
        self.toQuit=False
        self.lock=threading.Condition()
        self.move = None # { piece, move }
        
        self.func = None
        
        self.threads={}
    
    # def setGame(self, game=mainGame, side):
    #     self.side = side
    #     self.game = game.copypieces()
        
    def start(self, game, side, expire=5, func=None, threadnum=1):
        self.pause = self.toQuit =False
        self.elapse = time.time()
        self.move = None
        self.expire=expire; self.game = game; self.side = side
        self.threads.clear()
        
        # first check
        ok=game.mate(side)
        altside = piece.RED if(side==piece.BLACK) else piece.BLACK
        
        # if checked and see if it's game over
        if(ok == []):
            #dead, just pick any move
            while(True):
                pieces = [a for a in game.pieces if(a.side == side)]
                if(len(moves:=(p:=pieces[random.randint(0,len(pieces)-1)]).getAllMoves())>0):
                    self.move = { 'piece':p, 'move':moves[random.randint(0,len(moves)-1)] }
                    break
            
        elif(len(ok)==1 ): self.move = ok[0]
        else:
            # check if got killer move
            for p in ok:
                r = None
                pos=(p['piece'].pos,p['piece'].getMoveToPos(p['move']))
                if((pp:=game.hasPiece(pos[1]))!= None): 
                    game.pieces.remove(r:=pp)
                p['piece'].pos = pos[1]
                m = game.mate(altside)
                p['piece'].pos = pos[0]
                if(r != None): game.pieces.append(r)
                if(m==[]):
                    self.move = { 'piece':p['piece'], 'move':p['move'] }
                    break
                
        if(self.move): func();
        else: 
            self.lock.acquire()
            self.func = func
            for a in range(threadnum): 
                self.threads[thread:=threading.Thread(None,self.run)] = {}
                thread.start()
            self.lock.release()
            
        
    def pause(self):    
        self.lock.acquire()
        self.pause=True
        self.lock.release()
    
    def quit(self):    
        self.lock.acquire()
        self.toQuit=True
        self.lock.notify_all()
        self.lock.release()
        for (k,v) in self.threads.items(): k.join()
    
    def run(self):
        info=None
        
        ok=(game:=self.game.copypieces()).mate(side:=self.side)
        games=[game]
        choice = None

        while(True):
            self.lock.acquire()
            if(not self.toQuit and self.pause): 
                self.pause = True
                self.lock.wait()
                self.pause = False
            info = {'quit':self.toQuit,  'elapse':self.elapse, 'expire':self.expire}
            self.lock.release()
            
            if(info['quit'] or time.time()-info['elapse']>=info['expire']):
                break

            altside = piece.RED if(side==piece.BLACK) else piece.BLACK
            
            # random forest reserve
            game.history.append (ok[random.randint(0,len(ok)-1)])
            game.history[-1]['piece']=copy.copy(p:=game.history[-1]['piece'])
            if((r:=game.hasPiece(pos:=p.getMoveToPos(game.history[-1]['move'])))!=None):
                game.history.append ({'piece':r, 'move':(0,0)})
                game.pieces.remove(r)
                game.removed.append(r)
            p.pos = pos
            
            if((ok:=game.mate(side := altside)) == []):
                game.removed.append(game.gens[0 if(side==piece.RED) else 1])
                
            if(ok == [] or len(game.history)-len(game.removed) >  10):
                ok = (game := self.game.copypieces()).mate(side:=self.side)
                games.append(game)
                
        if(len(games)>0):
            for a in games:
                b = 0;
                for i in range(len(a.history)):
                    aa = a.history[i]['piece']
                    if(a.history[i]['move']==(0,0)):
                        if(aa.gettype() == piece.GEN): bb = 1000000 
                        elif(aa.gettype() == piece.GUARD): bb = 2000
                        elif(aa.gettype() == piece.XIANG): bb = 5000
                        elif(aa.gettype() == piece.KNIGHT): bb = 10000
                        elif(aa.gettype() == piece.CHARIOT): bb = 50000
                        elif(aa.gettype() == piece.CANNON): bb = 30000
                        elif(aa.gettype() == piece.PAWN): bb = 1000
                        
                        bb = bb* \
                            (len(a.history)-i)/len(a.history)*(len(a.history)-i)/len(a.history)
                        if(aa.side == self.side): bb = -bb
                        b += bb
                if(not choice or choice[1] < b): 
                    #print ((a.history[0],b))
                    choice = (a.history[0],b)
            
        func = self.func
        
        #only callbsack func if last function.
        self.lock.acquire()
        self.threads[threading.current_thread()] .update({ 'choice':choice,'done':True})
        for (k,v) in self.threads.items():
            if('done' not in v or not v['done']): 
                func = None
                break
            if(v['choice'][1]>choice[1]): choice = v['choice']
                   
        self.lock.release()    
        if(func): 
            self.move = choice[0]
            func()
        
aiThread = AIThread()


if(sys.argv[0] != ""):
    engine=run();
    qApp.exec()
    del engine
