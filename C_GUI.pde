import controlP5.*;
ControlP5 cp5, searchcp5, querycp5, slidercp5;

int suggestionsBackgroundH;

ArrayList<Screen> screens;
int currentScreen;

PFont niceFont, titleFont, mainTitleFont, searchResultsFont, queryFont;
PImage nextPageIcon, nextPageIconEmpty, previousPageIcon, previousPageIconEmpty;

public void initGUI() {
  noStroke();


  //init cp5s (need multiple so can draw in right order)
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  querycp5 = new ControlP5(this);
  querycp5.setAutoDraw(false);
  slidercp5 = new ControlP5(this);
  slidercp5.setAutoDraw(false);
  searchcp5 = new ControlP5(this);
  searchcp5.setAutoDraw(false);
  Label.setUpperCaseDefault(false);


  //init screens
  screens = new ArrayList<Screen>();
  currentScreen = -1;


  //init fonts
  niceFont = loadFont("ArialNarrow-24.vlw");
  titleFont = loadFont("Serif-18.vlw");
  mainTitleFont = loadFont("Serif-24.vlw");
  searchResultsFont = loadFont("Serif-14.vlw");
  queryFont = loadFont("Serif-18.vlw");


  //init widgets
  
  
  //init sort by query
  querycp5.addDropdownList("Queries")
    .setBroadcast(false)
    .setPosition(QUERIES_X, QUERIES_Y)
    .setWidth(QUERIES_W)
    .setBarHeight(QUERIES_BAR_H)
    .setItemHeight(QUERIES_ITEM_H)
    .setColorBackground(color(QUERIES_COL))
    .setItems(DDL_SORT_BY_STORY)
    .setOpen(false)
    .setLabel("Sort by:")
    .setFont(queryFont)
    .setColorForeground(color(QUERIES_COL-20))
    .setColorActive(color(QUERIES_COL-20))
    .setValue(0)//init to 'most relevant'
    ;


  //init search by query
  newDropdownList(querycp5, "Search By", QUERIES_X-querycp5.get("Queries").getWidth()-QUERIES_GAP, QUERIES_Y, QUERIES_W, QUERIES_BAR_H, QUERIES_ITEM_H, color(QUERIES_COL), DDL_SEARCH_BY)
    .setLabel("Search by:")
    .setFont(queryFont)
    .setColorForeground(color(QUERIES_COL-20))
    .setColorActive(color(QUERIES_COL-20))
    .setValue(0);//init to 'all'


  //init suggestions ddl
  newDropdownList("Suggestions", SEARCH_X, SUGGESTIONS_Y, SUGGESTIONS_W, color(255), color(0), color(200))
    .setItemHeight(SUGGESTIONS_ITEM_H)
    .setFont(queryFont)
    .setHeight(200)
    .setColorActive(color(200));
  cp5.get(DropdownList.class, "Suggestions").getCaptionLabel().setVisible(false);
  suggestionsBackgroundH=0;


  //init search bar
  newTextfield("Text Input", SEARCH_X, SEARCH_Y, SEARCH_W, SEARCH_H, color(SEARCH_BAR_COL), color(SEARCH_BAR_TEXT_COL));
  cp5.get(Textfield.class, "Text Input").getCaptionLabel().setVisible(false);
  PImage searchIcon = loadImage("search_icon2.png");//temp (use a better picture)
  searchIcon.resize(SUBMIT_W, SUBMIT_H);
  newButton("Submit", SUBMIT_X, SUBMIT_Y, SUBMIT_W, SUBMIT_H).setImage(searchIcon);


  //init slider
  slidercp5.addSlider("slider")
    .setBroadcast(false)
    .setPosition(SLIDER_X, SLIDER_Y)//should it start at top screen?
    .setSize(SLIDER_W, SLIDER_H)
    .setLabelVisible(false)
    .setColorBackground(color(BACKGROUND_COL))//would be nice if you could only see slider button
    .setColorForeground(color(SLIDER_CURSOR_COL))
    .setColorActive(color(SLIDER_CURSOR_COL))
    .setSliderMode(Slider.FLEXIBLE)
    .setValue(slidercp5.get(Slider.class, "slider").getMax())
    .setHandleSize(SLIDER_CURSOR_H)
    .setScrollSensitivity(SLIDER_SENSITIVITY)
    ;


  //init 'no results' widget
  slidercp5.addTextlabel("No results")
    .setPosition(RESULT_X, TOP_SCREEN_H+MAIN_MARGIN+2*MAIN_TITLE_FONT_H)
    .setColorBackground(color(255))
    .setColorForeground(color(255))
    .setColor(color(0))
    .setFont(searchResultsFont)
    .hide();


  //init home widget
  PImage logo = loadImage("logo.jpeg");
  logo.resize(LOGO_W, LOGO_H);
  newButton("Logo", LOGO_X, LOGO_Y, LOGO_W, LOGO_H).setImage(logo).setBroadcast(true);


  //init page arrows
  nextPageIcon = loadImage("nextpage.png");
  nextPageIcon.resize(PAGE_ARROW_SIZE, PAGE_ARROW_SIZE);
  nextPageIconEmpty = loadImage("nextpageempty.png");
  nextPageIconEmpty.resize(PAGE_ARROW_SIZE, PAGE_ARROW_SIZE);
  previousPageIcon = loadImage("previouspage.png");
  previousPageIcon.resize(PAGE_ARROW_SIZE, PAGE_ARROW_SIZE);
  previousPageIconEmpty = loadImage("previouspageempty.png");
  previousPageIconEmpty.resize(PAGE_ARROW_SIZE, PAGE_ARROW_SIZE);
  newButton("Next Page", NEXT_PAGE_X, PAGE_ARROW_Y, PAGE_ARROW_SIZE, PAGE_ARROW_SIZE).setImage(nextPageIconEmpty).setValue(0);
  newButton("Previous Page", PREVIOUS_PAGE_X, PAGE_ARROW_Y, PAGE_ARROW_SIZE, PAGE_ARROW_SIZE).setImage(previousPageIconEmpty).setValue(0);


  //get init results
  submitSearch("");
  screens.get(currentScreen).setCurrentScreen();
}



//----------------------------------events-----------------------------------------------

public void controlEvent(ControlEvent event) {
  switch (event.getController().getName()) { 
  case "Next Page":
    if (currentScreen < screens.size()-1) {
      currentScreen++;
      screens.get(currentScreen).setCurrentScreen();
      setPageArrowColours();
    }
    break;
  case "Previous Page":
    if (currentScreen >= 0) {
      currentScreen--;
      screens.get(currentScreen).setCurrentScreen();
      setPageArrowColours();
    }
    break;
  case "Logo": 
    cp5.get(Textfield.class, "Text Input").setText("");
    submitSearch(cp5.get(Textfield.class, "Text Input").getText());
    break;
  case "Queries":
  case "Search By":
    if (!searchListStory.isEmpty()) {
      String input;
      if (screens.get(currentScreen).getAuthor() == null) {
        input = cp5.get(Textfield.class, "Text Input").getText();
      } else {
        input =  screens.get(currentScreen).getAuthor();
      }
      submitSearch(input);
    } else {
      titleEvent(screens.get(currentScreen).getTitle());
    }
  case "Submit":
    if (!searchListStory.isEmpty()) {
      submitSearch(cp5.get(Textfield.class, "Text Input").getText());
    } else {
      titleEvent(screens.get(currentScreen).getTitle());
    }
    break;
  case "Suggestions":
    suggestionsEvent(event);
    break;
  case "slider":
    sliderEvent();
    break;
  }
}

//-----------------------------event functions-----------------------------------------------

//searches for results given search parameter and sorting options, and outputs those results to the screen as widgets
void submitSearch(String input) {
  if (!input.equals("")) {
    ArrayList<String> searchResults = applySearchByQuery(input);
    searchListStory = toStoryList(searchResults, NUM_SEARCH_RESULTS);
    searchListStory = applyQueryStory(searchListStory);
  } else {
    searchListStory = applyQueryFromEmpty(NUM_SEARCH_RESULTS);
  }

  toWidgetStories(searchListStory, MAIN_MARGIN);

  //set widgets
  setSliderRange(TOTAL_RESULTS_H*searchListStory.size()+MAIN_MARGIN);

  new StoryScreen(cp5.get(Textfield.class, "Text Input").getText(), false, null, null, null);
}

void suggestionsEvent(ControlEvent event) {
  //array index of searchResults is same as array index of each ddl element, and thus each ddl element's value
  ArrayList<String> searchResults = trie.getSearchResults(cp5.get(Textfield.class, "Text Input").getText(), NUM_SEARCH_RESULTS);
  String choice = searchResults.get((int)event.getValue());
  submitSearch(choice);
  suggestionsBackgroundH=0;
}

//triggered when slider is moved
//change position of all story widgets in accordance with slider
void sliderEvent() {
  float slider = slidercp5.get(Slider.class, "slider").getValue();

  //if story
  if (!searchListStory.isEmpty()) {
    sliderEventStory(slider);
  }

  //else if comment
  else if (!searchListComment.isEmpty()) {
    sliderEventComment(slider);
  }
}

void sliderEventStory(float slider) {
  float initY = slider+TOP_SCREEN_H+MAIN_MARGIN;

  String currentAuthor = screens.get(currentScreen).getAuthor();
  //set main widget
  if (currentAuthor != null) {
    searchcp5.get(currentAuthor).setPosition(searchcp5.get(currentAuthor).getPosition()[0], slider+TOP_SCREEN_H+MAIN_MARGIN);
    initY += RESULTS_MARGIN+MAIN_AUTHOR_FONT_H;
  }

  //set story widgets
  for (int i = 0; i < searchListStory.size(); i++) {
    Button title = searchcp5.get(Button.class, searchListStory.get(i).getTitle()+i);
    title.setPosition(title.getPosition()[0], initY+i*RESULTS_GAP);
    Button author = searchcp5.get(Button.class, searchListStory.get(i).getAuthor()+i);
    author.setPosition(author.getPosition()[0], initY+i*RESULTS_GAP+RESULT_H);
    Button date = searchcp5.get(Button.class, searchListStory.get(i).getDate()+i);
    date.setPosition(date.getPosition()[0], initY+i*RESULTS_GAP+2*RESULT_H);
  }
}

void sliderEventComment(float slider) {
  //set main widgets
  ArrayList<String> wrappedTitle = stringWrap(screens.get(currentScreen).getTitle(), RESULT_W, 10);
  int titleHeight = wrappedTitle.size()*MAIN_TITLE_FONT_H;
  Textlabel b = searchcp5.get(Textlabel.class, screens.get(currentScreen).getTitle());
  b.setPosition(b.getPosition()[0], slider+TOP_SCREEN_H+MAIN_MARGIN);
  String currentUrl = screens.get(currentScreen).getUrl();
  searchcp5.get(currentUrl).setPosition(searchcp5.get(currentUrl).getPosition()[0], slider+TOP_SCREEN_H+MAIN_MARGIN+titleHeight);
  if (searchcp5.get(currentUrl).getPosition()[1] < TOP_SCREEN_H-(RESULT_H-5)) searchcp5.get(currentUrl).hide();
  else searchcp5.get(currentUrl).show();

  //set comment widgets
  int txtHeight = TOP_SCREEN_H+RESULTS_MARGIN+MAIN_MARGIN+titleHeight;
  for (int i = 0; i < searchListComment.size(); i++) {

    String commentText = searchListComment.get(i).getText();
    ArrayList<String> wrappedText = stringWrap(searchListComment.get(i).getText(), RESULT_W, COMMENT_FONT_W);
    int currentTxtHeight = wrappedText.size()*COMMENT_FONT_H;

    Textlabel comment = searchcp5.get(Textlabel.class, commentText+i);
    comment.setPosition(comment.getPosition()[0], slider+txtHeight);
    Button author = searchcp5.get(Button.class, searchListComment.get(i).getAuthor()+i);
    author.setPosition(author.getPosition()[0], slider+(txtHeight+currentTxtHeight));
    Button date = searchcp5.get(Button.class, searchListComment.get(i).getDate()+i);
    date.setPosition(date.getPosition()[0], slider+(txtHeight+currentTxtHeight+author.getHeight()));

    txtHeight += currentTxtHeight+author.getHeight()+date.getHeight()+COMMENTS_GAP;
  }
}

//triggered when a title is clicked or searched
void titleEvent(String title) {
  searchListComment.clear();
  Story story = getStoryByLCTitle(title);
  ArrayList<Comment> comments = getCommentsForStory(story);
  
  comments = applyQueryComment(comments);
  
  //set queries items - reset when author clicked/submit
  querycp5.get(DropdownList.class, "Queries").setItems(DDL_SORT_BY_COMMENT);

  //clear all search widgets
  searchcp5 = new ControlP5(this);
  searchcp5.setAutoDraw(false);
  searchListStory.clear();

  ArrayList<Integer> heights = new ArrayList<Integer>();

  //convert to widgets
  heights = toWidgetComments(comments, -1, heights);
  int titleHeight = addMainTitleWidget(title);
  setNoResults(comments, "No comments");
  if (story != null) addUrlWidget(story.getUrl(), titleHeight);

  //change slider range 
  int totalCommentsHeight = heights.size()*(2*RESULT_H + RESULTS_MARGIN)+TOP_SCREEN_H+MAIN_MARGIN+MAIN_TITLE_FONT_H+URL_FONT_H;
  if (!comments.isEmpty()) slidercp5.get(Slider.class, "slider").setRange(-totalCommentsHeight, 0);
  else slidercp5.get(Slider.class, "slider").setRange(-SCREEN_H, 0);
  slidercp5.get(Slider.class, "slider").setValue(slidercp5.get(Slider.class, "slider").getMax());
}


//-------------------------toWidget functions--------------------------------


//creates a a widget representation of a story's comments
ArrayList<Integer> toWidgetComments(ArrayList<Comment> comments, int indent, ArrayList<Integer> heights) {
  //go to next indent level
  indent+=COMMENT_INDENT_W;

  for (Comment comment : comments) {
    //next comment widget
    int i = heights.size();

    //add each comment to global (for use with slider)
    searchListComment.add(comment);

    //convert commentText to wrapped representation
    String commentText = comment.getText();
    ArrayList<String> commentLines = stringWrap(commentText, RESULT_W-indent, COMMENT_FONT_W);
    String wrappedComment = String.join("\n", commentLines);

    //add widgets
    addCommentWidget(commentText, wrappedComment, i, indent, 0);
    addAuthorWidget(comment.getAuthor(), i, indent, 0);
    addDateWidget(comment.getDate(), i, indent, 0);

    //add to height
    heights.add(commentLines.size());

    //repeat for kids, if any
    if (!comments.isEmpty()) {
      heights = toWidgetComments(comment.getKidsAsComments(), indent, heights);
    }
  }
  //return if comment has no more kids
  return heights;
}

//creates a widget representation of a story arraylist
void toWidgetStories(ArrayList<Story> stories, int y) {
  //clear all search widgets5
  searchcp5 = new ControlP5(this);
  searchcp5.setAutoDraw(false);
  searchListComment.clear();
  setNoResults(stories, "No results");

  float initY = TOP_SCREEN_H+y;

  for (int i = 0; i < stories.size(); i++) {
    addTitleWidget(stories.get(i).getTitle(), i, 0, initY+i*RESULTS_GAP, stories.get(i).getUrl());
    addAuthorWidget(stories.get(i).getAuthor(), i, 0, initY+i*RESULTS_GAP+RESULT_H);
    addDateWidget(stories.get(i).getDate(), i, 0, initY+i*RESULTS_GAP+2*RESULT_H);
  }
}

//add search widget functions
//with built-in event functions

//when clicked goes to comments for that title
Button addTitleWidget(final String title, int index, int indent, float y, final String url) {
  String formattedTitle = enforceMaxLength(title, RESULT_W/TITLE_FONT_W);
  Button b = searchcp5.addButton(title+index)
    .setPosition(RESULT_X+indent, y)
    .setHeight(RESULT_H)
    .setWidth(formattedTitle.length()*TITLE_FONT_W)
    .setColorBackground(color(BACKGROUND_COL))
    .setColorForeground(color(BACKGROUND_COL))//sets hover col
    .setLabel(formattedTitle)
    .setFont(titleFont)
    .onPress(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (mouseY > TOP_SCREEN_H) {
        if (!(querycp5.get(DropdownList.class, "Queries").isOpen() && querycp5.get("Queries").isMouseOver()) && 
          !(querycp5.get(DropdownList.class, "Search By").isOpen() && querycp5.get("Search By").isMouseOver())) {
          titleEvent(theEvent.getController().getLabel());
          new CommentScreen(theEvent.getController().getLabel(), true, null, title, url);
        }
      }
    }
  }
  );
  b.getCaptionLabel()
    .setColor(color(TITLE_TEXT_COL))
    .alignX(int(searchcp5.get(Controller.class, title+index).getPosition()[0]));
  return b;
}
Textlabel addCommentWidget(String comment, String wrappedComment, int index, int indent, float y) {
  //note: using Textlabel and stringWrap instead of Textarea (with built in wrapping) as there's a bug with that controller
  return searchcp5.addTextlabel(comment+index)
    .setPosition(RESULT_X+indent-4, y)
    .setWidth(RESULT_W)
    .setText(wrappedComment)
    .setFont(searchResultsFont)
    .setColorValue(color(COMMENT_TEXT_COL));
}
//when clicked goes to author's page
Button addAuthorWidget(final String author, int index, int indent, float y) {
  Button b = searchcp5.addButton(author+index)
    .setPosition(RESULT_X+indent, y)
    .setWidth(author.length()*AUTHOR_FONT_W)
    .setColorBackground(color(BACKGROUND_COL))
    .setColorForeground(color(BACKGROUND_COL))//sets hover col
    .setLabel(author)
    .setFont(searchResultsFont)
    .onPress(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (mouseY > TOP_SCREEN_H) {
        if (!(querycp5.get(DropdownList.class, "Queries").isOpen() && querycp5.get("Queries").isMouseOver()) && 
          !(querycp5.get(DropdownList.class, "Search By").isOpen() && querycp5.get("Search By").isMouseOver())) {
          slidercp5.get(Slider.class, "slider").setValue(slidercp5.get(Slider.class, "slider").getMax());
          querycp5.get(DropdownList.class, "Queries").setItems(DDL_SORT_BY_STORY);
          String name = theEvent.getController().getLabel();
          searchListStory = findAuthor(name);
          toWidgetStories(searchListStory, RESULTS_MARGIN+MAIN_MARGIN+MAIN_AUTHOR_FONT_H);
          addMainAuthorWidget(name);
          new StoryScreen(name, true, author, null, null);
        }
      }
    }
  }
  );
  b.getCaptionLabel()
    .setColor(AUTHOR_TEXT_COL)
    .alignX(int(searchcp5.get(Controller.class, author+index).getPosition()[0]));
  return b;
}
Button addDateWidget(String date, int index, int indent, float y) {
  Button b = searchcp5.addButton(date+index)
    .setPosition(RESULT_X+indent, y)
    .setWidth(date.length()*DATE_FONT_W)
    .setColorBackground(color(BACKGROUND_COL))
    .setColorForeground(color(BACKGROUND_COL))//sets hover col
    .setFont(searchResultsFont)
    .setLabel(date);
  b.getCaptionLabel()
    .setColor(SEARCH_RESULTS_TEXT_COL)
    .alignX(int(searchcp5.get(Controller.class, date+index).getPosition()[0]));
  return b;
}
void addMainAuthorWidget(String author) {
  searchcp5.addTextlabel(author)
    .setPosition(RESULT_X-4, TOP_SCREEN_H+MAIN_MARGIN)
    .setText(author)
    .setColorBackground(color(BACKGROUND_COL))
    .setColor(color(MAIN_TITLE_COL))
    .setFont(mainTitleFont);
}
int addMainTitleWidget(String title) {
  ArrayList<String> wrappedTitle = stringWrap(title, RESULT_W, 10);
  String txt = String.join("\n", wrappedTitle);
  searchcp5.addTextlabel(title)
    .setPosition(RESULT_X-4, TOP_SCREEN_H+MAIN_MARGIN)
    .setText(txt)
    .setColorBackground(color(BACKGROUND_COL))
    .setColor(color(MAIN_TITLE_COL))
    .setFont(mainTitleFont);
  return wrappedTitle.size()*MAIN_TITLE_FONT_H;
}
//when clicked links to url
void addUrlWidget(final String url, int titleHeight) {
  if (!url.equals("")) {
    searchcp5.addButton(url)
      .setPosition(RESULT_X, TOP_SCREEN_H+MAIN_MARGIN+titleHeight)
      .setLabel(url).setColorForeground(color(BACKGROUND_COL))
      .setFont(searchResultsFont)
      .setWidth(url.length()*URL_FONT_W)
      .setColorBackground(color(BACKGROUND_COL))
      .onPress(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (!(querycp5.get(DropdownList.class, "Queries").isOpen() && querycp5.get("Queries").isMouseOver()) && 
          !(querycp5.get(DropdownList.class, "Search By").isOpen() && querycp5.get("Search By").isMouseOver())) {
          slidercp5.get(Slider.class, "slider").setValue(slidercp5.get(Slider.class, "slider").getMax());
          link(url);
        }
      }
    }
    ).getCaptionLabel()
      .setColor(URL_COL)
      .alignX(int(searchcp5.get(url).getPosition()[0]));
  } else {
    searchcp5.addTextlabel(url)
      .setPosition(RESULT_X, TOP_SCREEN_H+MAIN_MARGIN+titleHeight)
      .setText("no url").setColorBackground(BACKGROUND_COL)
      .setFont(searchResultsFont)
      .setColor(SEARCH_RESULTS_TEXT_COL);
  }
}


/*
-----------------------------newWidget functions-----------------------------------------------
 
 (for ease of use - mostly useless)
 
 standard order for addWidget function:
 //<T> newT(String name, int x, int y)                            //with standard size and colours
 //<T> newT(String name, int x, int y, int w, int h)              //with standard colours
 //<T> newT(String name, int x, int y, int w, int h, color col)   //with custom colours
 can append other parameters where necessary
 */

/*
how to add colours to widgets (not exhaustive)
 cp5.get(theName).setColorBackground(col);  //standard background col
 cp5.get(theName).setColorForeground(col);  //mouseHover col
 cp5.get(theName).setColorActive(col);      //mousePressed col
 
 cp5.get(theName).setColorValue(col)        //sets text col
 
 bar chart:
 cp5.get(theName).setColors("chart name", color(mainColour), color(otherColour)); // 1st sets main colour, 2nd sets colour it fades into (not necessary)
 
 */


//add Textarea with standard colours and font
//note: how to change scrollbar size?

Textarea newTextarea(int x, int y, String txt) {
  return cp5.addTextarea("")
    .setPosition(x, y)
    .setText(txt)
    .setFont(niceFont)
    .hide()
    ;
}

Textarea newTextarea(int x, int y, int w, int h, String txt) {
  return cp5.addTextarea("")
    .setPosition(x, y)
    .setSize(w, h)
    .setText(txt)
    .setFont(niceFont)
    .hide()
    ;
}


Textarea newTextarea(String name, int x, int y, int w, int h, color backgroundCol, String txt) {
  return cp5.addTextarea(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setColorBackground(backgroundCol)
    .setText(txt)
    .setFont(niceFont)
    .hide()
    ;
}

//add Textarea with standard colours and customisabe font
Textarea newTextarea(String name, int x, int y, int w, int h, String txt, PFont font) {
  return cp5.addTextarea(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setText(txt)
    .setFont(font)
    .hide()
    ;
}

//add Textarea with customisable colours and customisabe font
Textarea newTextarea(String name, int x, int y, int w, int h, color textCol, color backgroundCol, String txt, PFont font) {
  return cp5.addTextarea(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setColor(textCol)
    .setColorBackground(backgroundCol)
    .setText(txt)
    .setFont(font)
    .hide()
    ;
}

//add Textfield with standard colours
Textfield newTextfield(String name, int x, int y, int w, int h) {
  return cp5.addTextfield(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setAutoClear(false)
    ;
}

//add Textfield
//(incomplete)
Textfield newTextfield(String name, int x, int y, int w, int h, color col, color cursorCol) {
  return cp5.addTextfield(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setAutoClear(false)
    .setColorBackground(col)
    .setColorForeground(col)
    .setColorActive(col)
    .setColor(cursorCol)
    .setColorCursor(cursorCol)
    .setFont(niceFont)
    ;
}

//add Button with standard size and colours
Button newButton(String name, int x, int y) {
  return cp5.addButton(name)
    .setPosition(x, y)
    ;
}

//add Button with standard colours
Button newButton(String name, int x, int y, int w, int h) {
  return cp5.addButton(name)
    .setBroadcast(false)
    .setPosition(x, y)
    .setSize(w, h)
    ;
}

//add Button
Button newButton(String name, int x, int y, int w, int h, color col) {
  return cp5.addButton(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setColorBackground(col)//standard background col
    .setColorForeground(col)//mouseHover col
    .setColorActive(col)//mousePressed col
    ;
}

//add Chart
//note: data should be ArrayList<T>? -> ArrayList<Integer> data, where for each data.get(i).score is done outside of the function
Chart newChart(String name, int x, int y, int w, int h, String dataName, ArrayList<Story> data) {
  Chart chart = cp5.addChart(name)
    .setPosition(x, y)
    .setSize(w, h)
    .setView(Chart.BAR_CENTERED) //should be a paramter
    ;

  //create data set
  chart.addDataSet(dataName)
    .setData(dataName, new float[data.size()]);

  //fill data set
  for (int i = 0; i < data.size(); i++) {
    chart.push(dataName, data.get(i).score);
  }
  println(chart.getResolution());
  return chart;
}

//updates chart with new data from a new arrayList
void updateChart(String name, String dataName, ArrayList<Story>data) {
  Chart myChart = (Chart)cp5.get(name);
  myChart.removeDataSet(dataName);
  myChart.addDataSet(dataName)
    .setData(dataName, new float[data.size()]);
  int min = Integer.MAX_VALUE;
  int max = 0;
  for (int i=0; i<data.size(); i++) {
    myChart.push(dataName, data.get(i).score);
    min = data.get(i).score;
    max = data.get(i).score;
  }
  myChart.setRange(min, max);
}

//add empty DropdownList with standard size and colours
DropdownList newDropdownList(String name, int x, int y) {
  return cp5.addDropdownList(name)
    .setPosition(x, y)
    .setOpen(false)
    ;
}

//add empty DropdownList with standard height and colours
DropdownList newDropdownList(String name, int x, int y, int w) {
  return  cp5.addDropdownList(name)
    .setPosition(x, y)
    .setWidth(w)
    .setOpen(false)
    ;
}

//add empty DropdownList with standard colours
DropdownList newDropdownList(String name, int x, int y, int w, int h) {
  return  cp5.addDropdownList(name)
    .setPosition(x, y)
    .setWidth(w)
    .setBarHeight(h)
    .setItemHeight(h)
    .setOpen(false)
    ;
}

//add empty DropdownList with standard height
DropdownList newDropdownList(String name, int x, int y, int w, color backCol, color textCol) {
  return  cp5.addDropdownList(name)
    .setPosition(x, y)
    .setWidth(w)
    .setColorBackground(backCol)
    .setColorValue(textCol)
    .setOpen(false)
    ;
}

//add empty DropdownList with standard height
DropdownList newDropdownList(String name, int x, int y, int w, color backCol, color textCol, color hoverCol) {
  return cp5.addDropdownList(name)
    .setBroadcast(false)
    .setPosition(x, y)
    .setWidth(w)
    .setColorBackground(backCol)
    .setColorValue(textCol)
    .setColorForeground(hoverCol)
    .setOpen(false)
    ;
}

//add DropdownList with standard size and colours
DropdownList newDropdownList(String name, int x, int y, String[] items) {
  return cp5.addDropdownList(name)
    .setPosition(x, y)
    .setItems(items) //sets values automatically
    .setOpen(false)
    ;
}

//add DropdownList with standard width and colours
DropdownList newDropdownList(String name, int x, int y, int h, String[] items) {
  return  cp5.addDropdownList(name)
    .setPosition(x, y)
    .setBarHeight(h)
    .setItems(items)
    .setOpen(false)
    ;
}

//add DropdownList with standard colours
DropdownList newDropdownList(String name, int x, int y, int w, int barH, int itemH, String[] items) {
  return cp5.addDropdownList(name)
    .setPosition(x, y)
    .setWidth(w)
    .setItems(items)
    .setBarHeight(barH)
    .setItemHeight(itemH)
    .setOpen(false)
    ;
}

//add DropdownList
DropdownList newDropdownList(ControlP5 cp5, String name, int x, int y, int w, int barH, int itemH, color col, String[] items) {
  return cp5.addDropdownList(name)
    .setBroadcast(false)
    .setPosition(x, y)
    .setWidth(w)
    .setBarHeight(barH)
    .setItemHeight(itemH)
    .setColorBackground(col)
    .setItems(items)
    .setOpen(false)
    ;
}


//-----------------------------misc functions-----------------------------------------------

//returns true if mouse is over an area
boolean isFocus(int x, int y, int w, int h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}

//if there are no searchResults, will show a widget with given text
void setNoResults(ArrayList searchResults, String text) {
  slidercp5.get("No results").hide();
  if (searchResults.isEmpty()) {
    slidercp5.get(Textlabel.class, "No results").show()
      .setText(text);
  }
}

//converts string to arraylist of strings whose lengths are no greater than a desired length
//i.e. wraps a string about a length
ArrayList<String> stringWrap(String text, int lineLength, int fontWidth) {
  ArrayList<String> output = new ArrayList();
  final int maxCharsInLine = lineLength/fontWidth;
  int l; //rename
  while (text.length() > maxCharsInLine || text.contains("\r\n")) {
    l = text.indexOf("\r\n");
    if (l < 0 || l > maxCharsInLine) {
      for (l = maxCharsInLine; l > 0 && text.charAt(l) != 32; l--) ;
      l = l == 0 ? maxCharsInLine : l;
      output.add(text.substring(0, l));
      for (; l < text.length() && text.charAt(l) == 32; l++); //remove spaces
      if (l != 0) {
        text = text.substring(l);
      }
    } else if (l == 0) {
      output.add("");
      text = text.substring(2);
    } else {
      output.add(text.substring(0, l));
      for (; l < text.length() && text.charAt(l) == 32; l++); //remove spaces
      if (l != 0) {
        text = text.substring(l);
      }
    }
  }
  output.add(text);
  return output;
}

//converts any uncoded-ascii chars to coded-ascii chars
String formatString(String txt) {
  StringBuilder text = new StringBuilder(txt.replace("\n", "\r\n").replace("<p>", "\r\n"));
  for (int i = 0; i < text.length(); i++) {
    if (text.charAt(i)=='&' && text.charAt(i+1)=='#') {
      int asciiValue = 10*(text.charAt(i+2)-48) + text.charAt(i+3)-48;
      String ascii = Character.toString((char) asciiValue);
      text.replace(i, i+5, ascii);
    }
  }
  return text.toString();
}

//converts a string that's too long to have '...' on the end
String enforceMaxLength(String str, int maxLength) {
  StringBuilder b = new StringBuilder(str);
  if (b.length() > maxLength) { 
    b.replace(maxLength-3, b.length(), "...");
    str = b.toString();
  }
  return str;
}

//sets page arrow colours based on if currentScreen is the first, last, or other screen
void setPageArrowColours() {
  Controller prev = cp5.get(Controller.class, "Previous Page");
  prev.setBroadcast(false);
  if (currentScreen == 0) {//is first
    prev.setImage(previousPageIconEmpty);
    prev.setValue(0);
  } else {
    prev.setImage(previousPageIcon);
    prev.setValue(1);
  }
  prev.setBroadcast(true);
  Controller next = cp5.get(Controller.class, "Next Page");
  next.setBroadcast(false);
  if (screens.size() - currentScreen == 1) {//is last
    next.setImage(nextPageIconEmpty);
    next.setValue(0);
  } else {
    next.setImage(nextPageIcon);
    next.setValue(1);
  }
  next.setBroadcast(true);
}

//sets range of slider based on height 
void setSliderRange(int height) {
  float range = 0.01;//negligibly small
  if (height > SCREEN_H-TOP_SCREEN_H) {
    range = height - (SCREEN_H-TOP_SCREEN_H);
  }
  slidercp5.get(Slider.class, "slider").setRange(-range, 0);
}
