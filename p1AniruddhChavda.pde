//Import libraries
import controlP5.*;
import processing.sound.*;
import guru.ttslib.*;
import g4p_controls.*;

 
//Text to Speech object creation
TTS tts;

// controlP5 object
ControlP5 controlP5; 

//Background Image & microwave open and close Image
PImage bg, door1,door2;

//MIN & SEC of Display
PImage[] fourDigits = new PImage[4]; 

//0-9 digits images
PImage[] Digits = new PImage[10]; 

//Colon(:) to use between Min and Sec
PImage colon;

//Store the CHaracters "P" & "L" (short form of power) 
PImage[] display_PL = new PImage[2];

//Display power Level
PImage[] display_PL_image = new PImage[2];

//beep and longBeep sound
SoundFile beep_sound, longBeep_sound;

//Start and Stop button
GImageButton stop_button, start_button; 

//common knob size
int knob_radius = 200;

//knob of power
Knob pl;
int knob1_x = 500;
int knob1_y = 100;
String text_power_level = "Power level: ";

//knob of Time
Knob knob2_time;
int knob2_x = knob1_x;
int knob2_y = 400;
String text_time = "Power level: ";

//counter
int count_time = 0;

//Microwave on = true, off = false
boolean running = false;

//Button to open close door
Button b1;
String b1text ="   Click to \n\nOpen/Close";

//Initial disable counter for text to speech
int disableCounter =0;


////////////////////////////////////////////////////// SETUP !!///////////////////////////////////////////////////////////////////////////


void setup()
{
  //Size same as BG Image size
  size(833,1000);
  smooth();
  
  bg = loadImage("data/background/BG.jpg"); //Load BG Image
  background(bg); //Set BG Image
  
  controlP5 = new ControlP5(this); //Initialize object
  
  // change the default font to Verdana
  PFont p = createFont("Verdana",20); //set label size to 20
  ControlFont font = new ControlFont(p); //create font object
  controlP5.setFont(font); //set font
  
  //Add button for open and close
  b1 = controlP5.addButton(b1text)
  .setPosition(500,700)
  .setSize(333,300)
  .setColorForeground(color(160,160,160))
  .setColorBackground(color(160, 160, 160))
  .setColorValue(color(160, 160, 160))
  .setColorActive(color(60,0,0))
  .setSwitch(false)
   ;
  
 // Power Level knob
 // parameters : name, minimum, maximum, default value (float, x, y, diameter
  pl = controlP5.addKnob("knob1",0,10,5,knob1_x,knob1_y,knob_radius);
  pl.setCaptionLabel("POWER LEVEL")
    .setNumberOfTickMarks(10)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(160, 160, 160))
    .setColorActive(color(60,0,0))
    .setColorValue(color(160, 160, 160))
    .setTickMarkWeight(2.00)
    .setTickMarkLength(5)
    .getCaptionLabel().setColor(color(255, 255, 255) ).setSize(20);


 // Time knob
 // parameters : name, minimum, maximum, default value (float, x, y, diameter
  knob2_time = controlP5.addKnob("knob2",0,30,0,knob2_x,knob2_y,knob_radius);
  knob2_time.setCaptionLabel("TIME")
    .setColorForeground(color(255))
    .setColorBackground(color(160, 160, 160))
    .setColorActive(color(60,0,0))
    .setColorValue(color(0, 0, 0))
    .setNumberOfTickMarks(30)
    .snapToTickMarks(true)
    .setViewStyle(Knob.ELLIPSE)
    .setTickMarkWeight(2.00)
    .setTickMarkLength(5)
    .getCaptionLabel().setColor(color(255, 255, 255) ).setSize(20);
    
// Load Sound
   beep_sound = new SoundFile(this, "sound/button.mp3");
   longBeep_sound = new SoundFile(this, "sound/done.mp3");
  
  
// Load 9 digits and initialize 4 digits to 0 for starting diaplsy
  for (int i=0; i<10; i++){
    Digits[i] = loadImage("screen/" + i + ".PNG");
    if(i<4)
    {
      fourDigits[i] = Digits[0];
    }
  }


//load power level image
display_PL[0] = loadImage("screen/p.PNG");
display_PL[1] = loadImage("screen/l.PNG");

//draw stop/cancel button
  stop_button = new GImageButton(this, 100, 500,
                          250, 120, new String [] {"button/stop.png","button/stop_a.png", "button/stop_a.png"} );
                          
//draw Start/Add 30s button
  start_button = new GImageButton(this, 100, 300,
                          250, 120, new String [] {"button/start.png", "button/start_a.png", "button/start_a.png"} );
  smooth();
    
  //Screen to display time
  fill(0, 0, 0); 
  rect(80, 40, 220, 150); 
  
       
  //draw colon(:)
  colon = loadImage("screen/colon.PNG");
  
  //Draw zero digits
  image(fourDigits[0],100, 50, 40, 50);
  image(fourDigits[0],140, 50, 40, 50);
  image(fourDigits[0],200, 50, 40, 50);
  image(fourDigits[0],240, 50, 40, 50);
  image(colon, 180, 50, 20, 50);
  
  //draw pl
  image(display_PL[0],100,110,40,50);
  image(display_PL[1],140,110,40,50);
  image(colon        ,180,110,20,50);
  image(fourDigits[0],200, 110, 40, 50);
  image(fourDigits[0],240, 110, 40, 50);
  
  //door1 & door2 init
  door1 = loadImage("door/close.PNG");
  door2 = loadImage("door/open.PNG");
  
  
  //draw microwave image
  image(door1,0,700,500,330);
  
//Initializing Text to Speech
  tts = new TTS();
  
  // Set 1 frame per second for counter logic to work
  frameRate(1);
 
}


////////////////////////////////////////////////////// DRAW !! ///////////////////////////////////////////////////////////////////////////


  void draw()
{
    if (count_time == 0){
    if (running){
      longBeep_sound.play();
      running = false;
      draw_realTimeDigits(fourDigits, Digits, count_time);
    }
  }
  else{
    if (count_time < 0){
       return; 
    }
    else{
      draw_realTimeDigits(fourDigits, Digits, count_time);
      count_time--; 
    }
  }
}


////////////////////////////////////////////////////// DRAW OVER !! /////////////////////////////////////////////////////////////////////////// 


////////////////////////////////////////////////////// LOGIC STARTS !!///////////////////////////////////////////////////////////////////////////


 void openDoor()
 {
   image(door2,0,700,500,330);
       tts.speak("The DOOR is Open");
       stop();
 }
 
 void closeDoor()
 {
   image(door1,0,700,500,330);
   beep_sound.play();
   tts.speak("The DOOR is closed"); 
 }
 
 void mousePressed()
 {
     if (mouseX > 0 && mouseX < 300 && mouseY > 0 && mouseY < 190) {
        add30s();
        pl.setValue(8.00);
        disableCounter+=30;
        tts.speak("Total Time for heating is "+disableCounter+" Seconds");
        tts.speak("Power Level 8");
        tts.speak("Remaining Time "+count_time);
  }
 }
 

String[] get_four_digits(int cur_time){
  String[] num = new String[4];
  int minutes = cur_time/60;
  int seconds = cur_time%60;

  if (minutes > 9){
    num[0] = str(minutes/10);
    num[1] = str(minutes%10);
  }
  else{
    num[0] = "0";
    num[1] = str(minutes);
  }

  num[2] = str(seconds/10);
  num[3] = str(seconds%10);

  return num;
}


boolean draw_realTimeDigits(PImage[] fourDigits, PImage[] Digits, int cur_time){
  String[] str_4_digits = get_four_digits(cur_time);
  for (int i=0; i<4; i++){
    fourDigits[i] = Digits[int(str_4_digits[i])];
  }
  draw_timeDigits(fourDigits);
  return true;
}

boolean draw_timeDigits(PImage[] fourDigits){
      image(fourDigits[0],100, 50, 40, 50);
      image(fourDigits[1],140, 50, 40, 50);
      image(fourDigits[2],200, 50, 40, 50);
      image(fourDigits[3],240, 50, 40, 50);
      image(colon, 180, 50, 20, 50);
      return true;
}

boolean draw_powerDigits(int num){
       if(num <= 9){
         display_PL_image[0] = Digits[0];
         display_PL_image[1] = Digits[int(num)];
         image(display_PL_image[0],200, 110, 40, 50);
         image(display_PL_image[1],240, 110, 40, 50);
       }
       else
       {
         display_PL_image[0] = Digits[1];
         display_PL_image[1] = Digits[0];
         image(display_PL_image[0],200, 110, 40, 50);
         image(display_PL_image[1],240, 110, 40, 50);
       }
      return true;
}

void handleButtonEvents(GImageButton button, GEvent event) {
  
  if (button == start_button) {
      add30s();
  }
  else if (button == stop_button) {
      stop();
  }
}

void add30s()
{
    beep_sound.play(); //play beep
    count_time += 30; // add 30s to the current countdown
    running = true;
}

void stop()
{
      beep_sound.play(); //play beep
      count_time = 0; // reset the current countdown
      draw_realTimeDigits(fourDigits, Digits, count_time);
      running=false;
      pl.setValue(0.00);
      disableCounter =0;
}

//handle knob
 void controlEvent(ControlEvent event) {
   
   if(event.isController()){
     if(event.getController().getName()=="knob1") {
       int pl_val = int(event.getController().getValue());
       draw_powerDigits(pl_val);
     }
    }
    
    if(event.getController().getName()=="knob2") {
    println(event.getController().getValue());
    int min = int(event.getController().getValue());
    count_time = min*60;
    running=true;
   }
   
   if(event.getController().getName()==b1text){
     if(b1.getBooleanValue()==true)
     {
       openDoor();
     }
     else
     {
       closeDoor();
     }
   }
 }
 
