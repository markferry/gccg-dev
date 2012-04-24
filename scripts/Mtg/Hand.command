if(msg.box != NULL)
  Msg("Loading {gold}Hand.command");

# ColorCardName(card id) - Return the name of the card, preceded by a color format code.
def ColorCardName
{
  push(color);
  color = Attr("color",ARG);
  if(find(" ",color) != NULL)
    return(" {gold}"+name(ARG)+"{reset},");
  else if(color == "White")
    return(" {white}"+name(ARG)+"{reset},");
  else if(color == "Blue")
    return(" {blue}"+name(ARG)+"{reset},");
  else if(color == "Black")
    return(" {gray}"+name(ARG)+"{reset},");
  else if(color == "Red")
    return(" {red}"+name(ARG)+"{reset},");
  else if(color == "Green")
    return(" {green}"+name(ARG)+"{reset},");
  else if(color == "Artifact")
    return(" {154,154,154}"+name(ARG)+"{reset},");
  else if(color == "Land")
    return(" {154,128,77}"+name(ARG)+"{reset},");
  else if(color == "Colorless")
    return(" {128,128,128}"+name(ARG)+"{reset},");
  else return " "+name(ARG)+",";
  color=pop();
}

def CommandHand
{
  push(cards);
  push(deck);
  push(i);
  push(h);
  h="{orange}Sample hand:";
  if(length(ARG)<1) cards = 7;
  else cards = toint(ARG[0]);
  deck=shuffle(decks{deck.name}{"deck"});
  
  if (cards > length(deck))
    Msg("{red}Not enough cards in the deck.");
  else if (cards < 1)
    Msg("{red}Nothing to do.");
  else
  {
    for(i)(seq(0,cards-1))
      h=h+ColorCardName(deck[i]);
    Msg(left(h,length(h)-1)+".");
  }
  h=pop();
  i=pop();
  deck=pop();
  cards=pop();
}

HELP{"any"}{"hand"}=("[n]","generate sample hand",NULL,
"Shuffle up the deck and deal out a sample hand of {yellow}n{white} cards, for testing your deck's consistency without having to go to a table. If not specified, {yellow}n{white} is 7.");

