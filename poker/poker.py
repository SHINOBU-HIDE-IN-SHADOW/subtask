from pickle import FALSE
from pickletools import markobject
import random
from time import sleep
from typing import Literal
class card:
    def __init__(self,mark,card):
        self.mark = mark
        self.card = card
    def __str__(self):
        return self.mark+" "+self.card
    def remark(self):
        return self.mark
    def recard(self):
        if self.card == "A":
            return 1
        elif self.card == "K":
            return 13
        elif self.card == "Q":
            return 12
        elif self.card == "J":
            return 11
        return int(self.card)

class game:
    def __init__(self):
        card=['A','2','3','4','5','6','7','8','9','10','J','Q','K']
        mark=['A','H','Q','D']
        self.mark = []
        for x in mark:
            for y in card:
                self.mark.append(x+y)
        self.player_hand = []
        self.table = []
    def start(self):
        self.givecard()
        self.setcard(3)
        self.printhand()
        self.printtable()
        sleep(2)
        self.setcard(1)
        self.printtable()
        sleep(2)
        self.setcard(1)
        self.printtable()
        self.printhand()
        self.check(self.player_hand + self.table)
    def sett(self,i,y):
        for x in range(i):
            b=random.choice(self.mark)
            self.mark.remove(b)
            y.append(card(b[0],b[1]))
    def printer(self,i,a):
        print(i)
        for x in a:
            print('<',flush=True,end='')
            print(x,flush=True,end='> ')
        print()
    def setcard(self,i):
        self.sett(i,self.table)
    def givecard(self):
        self.sett(2,self.player_hand)
    def printhand(self):
        self.printer("player hand:",self.player_hand)
    def printtable(self):
        self.printer("table card:",self.table)
    def checkflush(self,a):
        if a.count('A') == 5:
            return True
        elif a.count('H') == 5:
            return True
        elif a.count('Q') == 5:
            return True
        elif a.count('D') == 5:
            return True
        return False
    def checkstraight(self,a):
        b = list(set(a))
        le = 0
        for x in range(len(b)-1):
            if le == 5:
                return True;
            if b[x+1]-b[x]!=1:
                le = 0
            le+=1    
        return False
    def check(self,list):
        card = [x.recard() for x in list]
        mark = [x.remark() for x in list]
        b = [f for f in card if card.count(f) >1]
        a = set(b)
        for x in a:
            if b.count(x) == 4:
                b=[x for i in range(4)]
                break; 
            elif b.count(x) == 3:
                b=[x for i in range(3)]
                break; 
        c = 1 in card
        flush = self.checkflush(mark)
        straight = self.checkstraight(card)
        if c == True and flush == True and straight==True:
            print("royal flush")
        elif flush == True and straight==True:
            print("straight flush")
        elif len(b)==4 and len(a)!=2:
            print("four of a kind")
        elif len(b)==5:
            print("full house")
        elif flush == True:
            print("flush")
        elif straight==True:
            print("straight")
        elif len(b)==3:
            print("three of a kind")
        elif len(a)==2:
            print("two pair")
        elif len(a)==1:
            print("piar")
        else:
            print("high card")
gm = game()
gm.start()

