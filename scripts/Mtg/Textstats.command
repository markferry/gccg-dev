#
# Mtg Deck Statistics Script
# Original by Malakh
# Revamped by R. Jones
#

if(msg.box != NULL) {
	Msg("Loading {gold}Textstats.command");
}

#
# CommandTextstats - Display a text report of statistics on the currently selected deck.
#
def CommandTextstats
{
  push(totalcards);
  push(curdeck);
  curdeck=decks{deck.name}{"deck"};
  totalcards=length(decks{deck.name}{"deck"});

# make sure there is a deck selected  
  if(deck.name!=NULL && totalcards) {
    push(cardtypes);
    push(cardcolors);

#   cardtypes 0=Artifact 1=Creature 2=Enchantment 3=Instant 4=Land 5=Sorcery
###FUTURE: 6=Planeswalker 7=Tribal?

    cardtypes = (CountAttr(curdeck, "type", "Artifact"), CountAttr(curdeck, "type", "Creature"),
      CountAttr(curdeck, "type", "Enchantment"), CountAttr(curdeck, "type", "Instant"),
      CountAttr(curdeck, "type", "Land"), CountAttr(curdeck, "type", "Sorcery"));

#   cardcolors 0=White 1=Blue 2=Black 3=Red 4=Green 5=Multicolor

    cardcolors = (CountAttr(curdeck, "color", "White"), CountAttr(curdeck, "color", "Blue"),
      CountAttr(curdeck, "color", "Black"), CountAttr(curdeck, "color", "Red"),
      CountAttr(curdeck, "color", "Green"), CountAttr(curdeck, "color", " "));
  
# CMC curve should ignore lands
    curdeck=select("find(\"Land\",Attr(\"type\",#)) == NULL",curdeck);

    manacurve=(CountMtgManaEqual(curdeck,0), CountMtgManaEqual(curdeck,1),
      CountMtgManaEqual(curdeck,2), CountMtgManaEqual(curdeck,3),
      CountMtgManaEqual(curdeck,4), CountMtgManaEqual(curdeck,5),
      CountMtgManaEqual(curdeck,6), CountMtgManaEqual(curdeck,7),
      CountMtgManaEqual(curdeck,8), CountMtgManaGreater(curdeck,8));

    Msg("{orange} *** Mtg Deck Statistics *** ");

    Msg("{154,128,77}Lands {white}" + cardtypes[4] + " (" + (cardtypes[4]*100)/totalcards + 
      "%) || {gold} Creatures {white}" + cardtypes[1] + " (" +  (cardtypes[1]*100)/totalcards + 
      "%) || {gold} Enchantments {white}" + cardtypes[2] + " (" + (cardtypes[2]*100)/totalcards + 
      "%) || {gold} Instants {white}" + cardtypes[3] + " (" + (cardtypes[3]*100)/totalcards + 
      "%) || {gold} Sorceries {white}" + cardtypes[5] + " (" + (cardtypes[5]*100)/totalcards + "%)");

    Msg("{154,154,154}Artifacts {white}" + cardtypes[0] + " (" + (cardtypes[0]*100)/totalcards + 
      "%) || White " + cardcolors[0] + " (" + (cardcolors[0]*100)/totalcards +
      "%) || {blue} Blue {white}" + cardcolors[1] + " (" + (cardcolors[1]*100)/totalcards + 
      "%) || {64,64,64} Black {white}" + cardcolors[2] + " (" + (cardcolors[2]*100)/totalcards + 
      "%) || {red} Red {white}" + cardcolors[3] + " (" + (cardcolors[3]*100)/totalcards + 
      "%) || {green} Green {white}" + cardcolors[4] + " (" + (cardcolors[4]*100)/totalcards + 
      "%) || {gold} Multicolor {white}" + cardcolors[5] + " (" +  (cardcolors[5]*100)/totalcards + "%)");

    Msg("{hr}{orange}Mana Curve {red}[ Average: {yellow}" + format("%0.2f",MtgAverageMana(curdeck)) + 
      "{red} ]{green}[ 0: {white}"  + manacurve[0] + "{green} ]{red}[ 1: {white}" + manacurve[1] + 
      "{red} ]{green}[ 2: {white}"  + manacurve[2] + "{green} ]{red}[ 3: {white}" + manacurve[3] + 
      "{red} ]{green}[ 4: {white}"  + manacurve[4] + "{green} ]{red}[ 5: {white}" + manacurve[5] + 
      "{red} ]{green}[ 6: {white}"  + manacurve[6] + "{green} ]{red}[ 7: {white}" + manacurve[7] + 
      "{red} ]{green}[ 8: {white}"  + manacurve[8] + "{green} ]{red}[ 9+: {white}" + manacurve[9] + "{red} ]");
    cardcolors=pop();
    cardtypes=pop();
  }
  
  curdeck=pop();
  totalcards=pop();
}
