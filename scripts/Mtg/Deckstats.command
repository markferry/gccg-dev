#
# Mtg Deck Statistics Script
# Original by Malakh
# Revamped by R. Jones
#

if(msg.box != NULL) {
	Msg("Loading {gold}Deckstats.command");
}

# Reserve an object for the deckstats menu
mydeck.object=(obj=obj+1);

#
# CommandDeckstats - Displays a listbox reporting statistics on the currently selected deck.
#
def CommandDeckstats
{
  push(totalcards);
  push(curdeck);
  curdeck=decks{deck.name}{"deck"};
  totalcards=length(curdeck);
  


# Check to make sure there is a deck selected.
  if(deck.name!=NULL && totalcards) {
    del_object(mydeck.object);
    mydeck.box=create_listbox(350,270,mydeck.object,"{orange}Mtg Deck Statistics",100,("Type","Count","Percent","{red}Mana","{red}Count"),(100,40,50,40,40),11,(1,1,1,1,1));


    deckstats=(,);
    deckstats{"artifact"}=CountAttr(curdeck, "type", "Artifact");
    deckstats{"creature"}=CountAttr(curdeck, "type", "Creature");
    deckstats{"enchantment"}=CountAttr(curdeck, "type", "Enchantment");
    deckstats{"land"}=CountAttr(curdeck, "type", "Land");
    deckstats{"instant"}=CountAttr(curdeck, "type", "Instant");
    deckstats{"sorcery"}=CountAttr(curdeck, "type", "Sorcery");
    deckstats{"w"}=CountAttr(curdeck, "color", "White");
    deckstats{"u"}=CountAttr(curdeck, "color", "Blue");
    deckstats{"b"}=CountAttr(curdeck, "color", "Black");
    deckstats{"r"}=CountAttr(curdeck, "color", "Red");
    deckstats{"g"}=CountAttr(curdeck, "color", "Green");
  
# CMC curve should ignore lands
    curdeck=select("find(\"Land\",Attr(\"type\",#)) == NULL",curdeck);
  
    deckstats{"mana0"}=CountMtgManaEqual(curdeck,0);
    deckstats{"mana1"}=CountMtgManaEqual(curdeck,1);
    deckstats{"mana2"}=CountMtgManaEqual(curdeck,2);
    deckstats{"mana3"}=CountMtgManaEqual(curdeck,3);
    deckstats{"mana4"}=CountMtgManaEqual(curdeck,4);
    deckstats{"mana5"}=CountMtgManaEqual(curdeck,5);
    deckstats{"mana6"}=CountMtgManaEqual(curdeck,6);
    deckstats{"mana7"}=CountMtgManaEqual(curdeck,7);
    deckstats{"mana8"}=CountMtgManaEqual(curdeck,8);
    deckstats{"mana9"}=CountMtgManaGreater(curdeck,8);
    deckstats{"mana_avg"}=MtgAverageMana(curdeck);
  
    listbox_set_entry(mydeck.box,0,("{brown}Land",deckstats{"land"},
      tostr((deckstats{"land"}*100)/totalcards) + "%","{red}0",deckstats{"mana0"}));
    listbox_set_entry(mydeck.box,1,("{brown}Creature",deckstats{"creature"},
      tostr((deckstats{"creature"}*100)/totalcards) + "%","{red}1",deckstats{"mana1"}));
    listbox_set_entry(mydeck.box,2,("{brown}Artifact",deckstats{"artifact"},
      tostr((deckstats{"artifact"}*100)/totalcards) + "%","{red}2",deckstats{"mana2"}));
    listbox_set_entry(mydeck.box,3,("{brown}Enchantment",deckstats{"enchantment"},
      tostr((deckstats{"enchantment"}*100)/totalcards) + "%","{red}3",deckstats{"mana3"}));
    listbox_set_entry(mydeck.box,4,("{brown}Instant",deckstats{"instant"},
      tostr((deckstats{"instant"}*100)/totalcards) + "%","{red}4",deckstats{"mana4"}));
    listbox_set_entry(mydeck.box,5,("{brown}Sorcery",deckstats{"sorcery"},
      tostr((deckstats{"sorcery"}*100)/totalcards) + "%","{red}5",deckstats{"mana5"}));
    listbox_set_entry(mydeck.box,6,("{yellow}White",deckstats{"w"},
      tostr((deckstats{"w"}*100)/totalcards) + "%","{red}6",deckstats{"mana6"}));
    listbox_set_entry(mydeck.box,7,("{blue}Blue",deckstats{"u"},
      tostr((deckstats{"u"}*100)/totalcards) + "%","{red}7",deckstats{"mana7"}));
    listbox_set_entry(mydeck.box,8,("Black",deckstats{"b"},
      tostr((deckstats{"b"}*100)/totalcards) + "%","{red}8",deckstats{"mana8"}));
    listbox_set_entry(mydeck.box,9,("{red}Red",deckstats{"r"},
      tostr((deckstats{"r"}*100)/totalcards) + "%","{red}9+",deckstats{"mana9"}));
    listbox_set_entry(mydeck.box,10,("{green}Green",deckstats{"g"},
      tostr((deckstats{"g"}*100)/totalcards) + "%","{red}Avg",format("%0.2f",deckstats{"mana_avg"})));
      
    set_attr(mydeck.box,"visible",1);
    raise(mydeck.box);
  }

  curdeck=pop();
  totalcards=pop();
}

HELP{"chat"}{"deckstats"}=("","show deck statistics",
NULL,
"Open a window displaying a table of various statistics regarding the currently selected deck.");