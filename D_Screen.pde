class Screen {
  String search;
  int sortValue, searchByValue;
  boolean hasMainWidget;
  String author, title, url;

  Screen(String search, boolean hasMainWidget, String author, String title, String url) {
    
    //set values
    this.search=search;
    sortValue = int(querycp5.get("Queries").getValue());
    searchByValue = int(querycp5.get("Search By").getValue());
    this.hasMainWidget=hasMainWidget;
    this.author=author;
    this.title=title;
    this.url=url;

    //only add new screen if not same as previous screen
    if (currentScreen > 0) {//if previous screen exists
      Screen previousScreen = screens.get(currentScreen-1);
      if (!(search.equals(previousScreen.getSearch()) &&
        sortValue == previousScreen.getSortValue() &&
        searchByValue == previousScreen.getSearchByValue())) {
      } else {
        return;
      }
    }

    addNewScreen();
    setWidgets();
  }

  String getTitle() {
    return title;
  }
  String getAuthor() {
    return author;
  }
  String getUrl()
  {
    return url;
  }

  //adds screen to global list screens,
  //and sets currentScreen appropriately
  void addNewScreen() {

    //remove all screens that can't be accessed anymore
    screens.subList(currentScreen+1, screens.size()).clear();

    //add this to screens list
    screens.add(this);

    //remove earlier screen if max screens is reached
    if (screens.size() < MAX_SCREENS) {
      currentScreen++;
    } else {
      screens.remove(0);
    }

    setPageArrowColours();
  }

  //sets current screen to this
  void setCurrentScreen() {
    setWidgets();
    getResults();
  }

  //sets all widgets based to what they were when the screen was created
  void setWidgets() {
    //reset widgets
    querycp5.get(Controller.class, "Queries").setBroadcast(false);
    querycp5.get(Controller.class, "Search By").setBroadcast(false);


    querycp5.get(DropdownList.class, "Queries").setOpen(false);
    querycp5.get(DropdownList.class, "Search By").setOpen(false);
    cp5.get(DropdownList.class, "Suggestions").setOpen(false);
    slidercp5.get(Slider.class, "slider").setValue(slidercp5.get(Slider.class, "slider").getMax());

    //set ddl values
    querycp5.get("Queries").setValue(sortValue);
    querycp5.get("Search By").setValue(searchByValue);

    slidercp5.get(Slider.class, "slider").setBroadcast(true);
    querycp5.get(Controller.class, "Queries").setBroadcast(true);
    querycp5.get(Controller.class, "Search By").setBroadcast(true);
    cp5.get(Controller.class, "Suggestions").setBroadcast(true);
  }

  //sets new widgets based on 'search'
  void getResults() {
  }

  String getSearch() {
    return search;
  }
  int getSortValue() {
    return sortValue;
  }
  int getSearchByValue() {
    return searchByValue;
  }
}
class StoryScreen extends Screen {
  StoryScreen(String search, boolean hasMainWidget, String author, String title, String url) {
    super(search, hasMainWidget, author, title, url);
  }

  //sets story widgets
  @Override
    void getResults() {
    if (!search.equals("")) {
      searchListStory = findAuthor(search);
      if (searchListStory.isEmpty()) {
        ArrayList<String> searchResults = applySearchByQuery(search);
        searchListStory = toStoryList(searchResults, NUM_SEARCH_RESULTS);
      }
      searchListStory = applyQueryStory(searchListStory);
    } else {
      searchListStory = applyQueryFromEmpty(NUM_SEARCH_RESULTS);
    }
    int y = hasMainWidget ? RESULTS_MARGIN+MAIN_MARGIN+MAIN_AUTHOR_FONT_H : MAIN_MARGIN;
    toWidgetStories(searchListStory, y);
    if (hasMainWidget) addMainAuthorWidget(search);

    //set widgets
    setSliderRange(TOTAL_RESULTS_H*searchListStory.size()+MAIN_MARGIN+MAIN_AUTHOR_FONT_H);
    querycp5.get(DropdownList.class, "Queries").setItems(DDL_SORT_BY_STORY);
  }
}

class CommentScreen extends Screen {
  CommentScreen(String search, boolean hasMainWidget, String author, String title, String url) {
    super (search, hasMainWidget, author, title, url);
  }

  //sets comment widgets
  @Override
    void getResults() {
    titleEvent(search);
  }
}
