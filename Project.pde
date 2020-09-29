import java.util.NoSuchElementException;
ArrayList<JSONObject>stories, comments;
JSONArray storyArr, commentArr;
JSONObject ob;
BufferedReader reader;
String line;
ArrayList<Story> storyList, storiesByTime, storiesByScore, storiesByKids, noResult;
ArrayList<Comment> commentList, commentByTime;
ArrayList<Story> storyByAuthor;

Trie trie, authorTrie, titleTrie;//to distinguish between authors and titles
ArrayList<Story> searchListStory;
ArrayList<Comment> searchListComment;

void settings() {
  size(SCREEN_W, SCREEN_H);
}

//should split this up into functions~
void setup() {
  noResult = new ArrayList<Story>();
  storyByAuthor = new ArrayList<Story>();
  stories = new ArrayList<JSONObject>();
  comments = new ArrayList<JSONObject>();
  storyList = new ArrayList<Story>();
  commentList = new ArrayList<Comment>();
  //added
  storiesByScore = new ArrayList<Story>();
  storiesByTime= new ArrayList<Story>();
  storiesByKids= new ArrayList<Story>();
  commentByTime = new ArrayList<Comment>();
  //added

  //init Tries
  trie = new Trie();
  authorTrie = new Trie();
  titleTrie = new Trie();
  searchListStory = new ArrayList<Story>();
  searchListComment = new ArrayList<Comment>();

  //reader = createReader("entries.txt");

  //added start
  //sorts data (if necessary)
  sorter();
  //loads data into arrays (and loads storyList,commentList)
  loader(storiesByScore, storiesByTime, storiesByKids, commentByTime);
  //added end
  //pass story "type" into story
  //adding into arrayList<Story>
  //Changed stories to storiesByTime - John
  for (int j = 0; j < storiesByTime.size(); j++) {
    Story a  = new Story(storyArr.getJSONObject(j));
    //if not dead (shouldnt add to arr in first place if dead~)
    if (storyArr.getJSONObject(j).isNull("dead") || !storyArr.getJSONObject(j).getBoolean("dead")) {
      trie.add(a.getAuthor());
      authorTrie.add(a.getAuthor());
      String title = formatString(a.getTitle());
      trie.add(title);
      titleTrie.add(title);
    }
    //storyList.add(a);
  }
  //added start

  for (int i =0; i<storiesByTime.size(); i++) {
    storyList.add(storiesByTime.get(i));
  }

  for (int i =0; i<commentByTime.size(); i++) {
    commentList.add(commentByTime.get(i));
  }
  //added end
  // pass comment "type" into comment
  // adding to ArrayList<Comment>
  //for (int j = 0; j < comments.size(); j++) {
  //  Comment a = new Comment(comments.get(j));
  //  commentList.add(a);
  //}
  // create new ArrayList<Story> with the first index having the greatest time value
  // ArrayList<Story> changed = newestStory(storyList);
  // ArrayList<Comment> to test the function that returns comments associated with a story
  //ArrayList<Comment> test = getCommentsForStory(storyList.get(0));
  //for (int i = 0; i < test.size(); i++) {
  //  //println(test.get(i).toString());
  //}
  //println(test.size());

  //ArrayList<Story>a = storyList;
  //qsStT(a,1,a.size()-1);
  //for(int i =0;i<a.size();i++){
  // //println(a.get(i).getDate()); 
  //}
  //Test for author search
  storyByAuthor = findAuthor("pg");
  ////println(storyByAuthor.size());

  //GUI
  initGUI();
}

//draw widgets in a certain order
void draw() {
  background(BACKGROUND_COL);
  
  searchcp5.draw();
  slidercp5.draw();

  //top screen
  fill(TOP_SCREEN_COL);
  rect(0, 0, SCREEN_W, TOP_SCREEN_H);

  //edges of searchbar
  fill(SEARCH_BAR_COL);
  circle(SEARCH_X, SEARCH_Y+SEARCH_H/2, SEARCH_H);
  circle(SUBMIT_X+SUBMIT_W, SEARCH_Y+SEARCH_H/2, SEARCH_H);

  //slider cursor
  fill(SLIDER_CURSOR_COL);
  rect(SLIDER_X, SCREEN_H-slidercp5.get(Slider.class, "slider").getValuePosition()-SLIDER_CURSOR_H-SLIDER_W/2, SLIDER_W, SLIDER_CURSOR_H);
  circle(SLIDER_X+SLIDER_W/2, SCREEN_H-slidercp5.get(Slider.class, "slider").getValuePosition()-SLIDER_CURSOR_H-SLIDER_W/2-SLIDER_GAP_Y, SLIDER_W);
  circle(SLIDER_X+SLIDER_W/2, SCREEN_H-slidercp5.get(Slider.class, "slider").getValuePosition()-SLIDER_W/2-SLIDER_GAP_Y, SLIDER_W);

  querycp5.draw();

  //suggestions ddl background
  fill(SEARCH_BAR_COL);
  stroke(SUGGESTIONS_BORDER_COL);
  rect(SEARCH_X-1, SUGGESTIONS_Y, SUGGESTIONS_W+1, suggestionsBackgroundH);
  noStroke();

  cp5.draw();

  setCursor();
}

void keyPressed() {
  //move slider if up or down arrow pressed
  if (keyCode == UP) {
    slidercp5.get(Slider.class, "slider").scrolled(-1);
  } else if (keyCode == DOWN) {
    slidercp5.get(Slider.class, "slider").scrolled(1);
  }

  //set suggestions, and allow for 'enter' search
  if (cp5.get(Textfield.class, "Text Input").isFocus()) {
    
    //get suggestions
    String input = cp5.get(Textfield.class, "Text Input").getText();
    ArrayList<String> searchResults = new ArrayList<String>();
    
    //if backspace, need to remove last char from input 
    if (key > 0x21 && key < 0x7E) {  //if key == char
      input += key;
      searchResults = trie.getSearchResults(input, NUM_SEARCH_SUGGESTIONS);
    } else if (keyCode == BACKSPACE && input.length() > 0) { 
      input = input.substring(0, input.length()-1);
      searchResults = trie.getSearchResults(input, NUM_SEARCH_SUGGESTIONS);
    }
    
    //format if any results are too long
    for (int i = 0; i < searchResults.size(); i++) {
      searchResults.set(i, enforceMaxLength(searchResults.get(i), SUGGESTIONS_W/SUGGESTIONS_FONT_W));
    }
    
    //set suggestions dropdown to show results
    cp5.get(DropdownList.class, "Suggestions").setItems(searchResults); 
    if (!input.equals("")) {
      cp5.get(DropdownList.class, "Suggestions").setOpen(true);
      suggestionsBackgroundH=SUGGESTIONS_ITEM_H*cp5.get(DropdownList.class, "Suggestions").getItems().size()+SUGGESTIONS_BAR_H;
    } else suggestionsBackgroundH=0;

    //if enter pressed, search
    if (key == ENTER) {
      submitSearch(input);
    }
  }
}


void mousePressed() {
  //close suggestions if mousePressed elsewhere
  if (!isFocus(SEARCH_X, SEARCH_Y, SEARCH_W, SEARCH_H + suggestionsBackgroundH)) { 
    cp5.get(DropdownList.class, "Suggestions").setOpen(false);
    suggestionsBackgroundH=0;
  } //open suggestions dropdown if search bar is clicked on
  else if (!cp5.get(Textfield.class, "Text Input").getText().equals("")) {
    cp5.get(DropdownList.class, "Suggestions").setOpen(true);
    suggestionsBackgroundH=RESULT_H*cp5.get(DropdownList.class, "Suggestions").getItems().size()+SUGGESTIONS_BAR_H;
  }
}

//moves slider
void mouseWheel(MouseEvent e) {
  if (!(querycp5.get(DropdownList.class, "Queries").isOpen() && querycp5.get("Queries").isMouseOver()) && 
    !(querycp5.get(DropdownList.class, "Search By").isOpen() && querycp5.get("Search By").isMouseOver())) {
    slidercp5.get(Slider.class, "slider").scrolled(e.getCount());
  }
}

//sets what the cursor looks like depending on which widget is currenlty being hovered over
void setCursor() {
  if (cp5.get("Submit").isMouseOver() ||
    (cp5.get("Logo").isMouseOver()) ||
    (querycp5.isMouseOver() && mouseY > TOP_SCREEN_H) || 
    (searchcp5.isMouseOver()) ||
    (cp5.get("Next Page").isMouseOver() && cp5.get("Next Page").getValue()==1) ||
    (cp5.get("Previous Page").isMouseOver() && cp5.get("Previous Page").getValue()==1))
    cursor(HAND);
  else if (cp5.get("Text Input").isMouseOver()) cursor(TEXT);
  else cursor(ARROW);
}
