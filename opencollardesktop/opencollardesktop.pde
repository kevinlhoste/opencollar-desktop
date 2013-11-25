/*

0.83 -- selection of port
0.84 -- add gyro
*/

import controlP5.*;
ControlP5 controlP5;
import processing.serial.*;

int Mode=0; //1: live// 2: read //3: data chargées

Button bMessageBoxWarning1OK,bMessageBoxWarning1CANCEL,bMessageSaveOK,bMessageBoxError1OK,bMessageBoxOK,bDownload,b1,buttonLiveMode,buttonReadMode,buttonfwd1,buttonffwd10, buttonfffwd100, buttonrwd1, buttonrrwd10, buttonrrrwd100,buttonzoominx,buttonzoomoutx,buttonzoominy,buttonzoomouty;
Toggle toggleSaveToFile,toggleDrawFromFile,toggleAccX,toggleAccY,toggleAccZ,toggleGyroX,toggleGyroY,toggleGyroZ;
Slider slDownload;
Textlabel lMessageBoxError1,lMessageBoxSave1,lMessageBoxWarning1;
Textfield fileName1;
String defaultFileName="data";
String fileName="";
PFont f;
//colors 
int col = color(255);
int V1 = color(100,188,111);
int V2 = color(29,80,42);
int R1 = color(200,89,91);
int B1 = color(81,162,198);
int Y1 = color(207,209,121);
int Vi1 = color(115,97,167);
int C1 = color(92,196,194);
int NButton = color(0,0,0,180);
int NButton2 = color(0,0,0,120);
int NButton3 = color(0,0,0,1);
int Shadow = color(0,70);
boolean toggleValueV = false;
boolean toggleValueR = false;
boolean toggleValueB = false;

Serial myPort;                       // The serial port
int[] serialInArray = new int[3];    // Where we'll put what we receive                // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller
float[] dataX,dataY,dataZ,dataGyroX, dataGyroY, dataGyroZ;
String[] dataXYZ;
String[] file;
float graphMultX = 4; //graphMultX = gb_width/ max data points 
float graphMultY = 50; //gb heigth/pas63 400/3 old133
float graphMultGyroY = 400/250;
float max_x_point=250;
/*
Com settings
*/
int comSpeed=38400;
//origin of acc and gyro lines
int acc_VerticalOrigin=194;//old 410//194
int gyro_VerticalOrigin=502; //old 310
int startPos;
int endPos;
int currentPos;
int minPos=0;
int serialCount=0;
int g_winW             = 820;   // Window Width
int g_winH             = 620;   // Window Height
DropdownList ports;              //Define the variable ports as a Dropdownlist.
int Ss;                          //The dropdown list will return a float value, which we will connvert into an int. we will use this int for that).
String[] comList ;               //A string to hold the ports in.
boolean serialSet=false;               //A value to test if we have setup the Serial port.
boolean Comselected = false; 
boolean DisplayAccX = true;
boolean DisplayAccY = true;
boolean DisplayAccZ = true;
boolean DisplayGyroX = true;
boolean DisplayGyroY = true;
boolean DisplayGyroZ = true;
boolean DisplayGraphAxes=false;
boolean showMessageBoxError1=false;
boolean showMessageBoxWarning1=false; //error unsaved data
boolean showMessageBoxSave1=false;

float acc_range=4.0;
float gyro_range=250.0;
int WindowH = 700 ;
int WindowW = 1024 ;
ControlGroup messageBox,messageBoxError1,messageBoxWarning1,messageBoxSave1;
int showMessageBox=0;
int point_nb=0;
int sampling_rate=100;//in hz
int measurment_time=0; //in seconds
int verbose_value=0;


void setup() {
  //background(200);
  size(WindowW,WindowH,JAVA2D);
  controlP5 = new ControlP5(this);
//  controlP5.setColorLabel(0x00);
  //set the toggles
/*  toggleLiveMode= controlP5.addToggle("LiveMode",false,40,500,20,20); toggleLiveMode.setColorActive(color (0,250,0)); toggleLiveMode.setColorBackground (color(255, 0, 0));
  toggleReadMode= controlP5.addToggle("ReadMode",false,90,500,20,20); toggleReadMode.setColorActive(color (0,250,0)); toggleReadMode.setColorBackground (color(255, 0, 0));// déclencheurs live et lecture
  toggleSaveToFile= controlP5.addToggle("SaveToFile",false,140,500,20,20); toggleSaveToFile.setColorActive(color (0,250,0)); toggleSaveToFile.setColorBackground (color(255, 0, 0));
  toggleDrawFromFile= controlP5.addToggle("DrawFromFile", false,140,550,20,20); toggleDrawFromFile.setColorActive (color (250,0,0)); toggleDrawFromFile.setColorBackground (color(0,0,250));//toggle pour redessiner
  
  /*toggle enable curves*/
/*  toggleAccX= controlP5.addToggle("a",true,10,420,10,10); toggleAccX.setColorActive(color (255,0,0)); toggleAccX.setColorBackground (color(0, 0, 0)); toggleAccX.setLabelVisible(false);
  toggleAccY= controlP5.addToggle("b",true,10,440,10,10); toggleAccY.setColorActive(color (0,255,0)); toggleAccY.setColorBackground (color(0, 0, 0)); toggleAccY.setLabelVisible(false);
  toggleAccZ= controlP5.addToggle("c",true,10,460,10,10); toggleAccZ.setColorActive(color (0,0,255)); toggleAccZ.setColorBackground (color(0, 0, 0)); toggleAccZ.setLabelVisible(false);
  toggleGyroX= controlP5.addToggle("d",true,60,420,10,10); toggleGyroX.setColorActive(color (0,255,255)); toggleGyroX.setColorBackground (color(0, 0, 0)); toggleGyroX.setLabelVisible(false);
  toggleGyroY= controlP5.addToggle("e",true,60,440,10,10); toggleGyroY.setColorActive(color (0,102,102)); toggleGyroY.setColorBackground (color(0, 0, 0)); toggleGyroY.setLabelVisible(false);
  toggleGyroZ= controlP5.addToggle("f",true,60,460,10,10); toggleGyroZ.setColorActive(color (102,102,205)); toggleGyroZ.setColorBackground (color(0, 0, 0)); toggleGyroZ.setLabelVisible(false);
  //buttons forward and reward
/*  buttonfwd1= controlP5.addButton("fwd1",0, 260, 450, 30, 20); buttonfwd1.setColorActive (color(13, 233, 79)); buttonfwd1.setColorBackground (color(153, 102, 255));
  buttonffwd10= controlP5.addButton("ffwd10",0, 260, 500, 40, 20); buttonffwd10.setColorActive (color(46, 210, 62)); buttonffwd10.setColorBackground (color(153, 51, 204));
  buttonfffwd100= controlP5.addButton("fffwd100",0, 260, 550, 50, 20); buttonfffwd100.setColorActive (color(36, 230, 62)); buttonfffwd100.setColorBackground (color(153, 0, 153));
  buttonrwd1= controlP5.addButton("rwd1",0, 360, 450, 30, 20); buttonrwd1.setColorActive (color(255, 0, 0)); buttonrwd1 .setColorBackground (color(255, 204, 102));
  buttonrrwd10= controlP5.addButton("rrwd10",0, 360, 500, 40, 20); buttonrrwd10.setColorActive (color(255, 0, 0)); buttonrrwd10.setColorBackground (color(255, 153, 51));
  buttonrrrwd100= controlP5.addButton("rrrwd100",0, 360, 550, 50, 20); buttonrrrwd100.setColorActive (color(255, 0, 0)); buttonrrrwd100.setColorBackground (color(255, 105, 0));
  */
  //buttons for zooming in and out in x and y patterns
 /* buttonzoominx= controlP5.addButton("zoominx",0, 470, 500, 40, 20); buttonzoominx.setColorActive (color(255, 0, 0)); buttonzoominx.setColorBackground (color(255, 185, 15));
  buttonzoomoutx= controlP5.addButton("zoomoutx",0, 470, 552, 45, 20); buttonzoomoutx.setColorActive (color(255, 0, 0)); buttonzoomoutx.setColorBackground (color(255, 69, 0));
  buttonzoominy= controlP5.addButton("zoominy",0, 530, 500, 40, 20); buttonzoominy.setColorActive (color(255, 0, 0)); buttonzoominy.setColorBackground (color(202, 255, 112));
  buttonzoomouty= controlP5.addButton("zoomouty",0, 530, 552, 45, 20); buttonzoomouty.setColorActive (color(255, 0, 0)); buttonzoomouty.setColorBackground (color(127, 255, 0));
  */
  
  dataX = new float[300000];
  dataY = new float[300000];
  dataZ = new float[300000];
  dataGyroX = new float[300000];
  dataGyroY = new float[300000];
  dataGyroZ = new float[300000];
  
  currentPos=0;
  startPos=0;
  endPos=0;
  //Make a dropdown list calle ports. Lets explain the values: ("name", left margin, top margin, width, height (84 here since the boxes have a height of 20, and theres 1 px between each item so 4 items (or scroll bar).
  //ports = controlP5.addDropdownList("list-1",40,570,100,84);
  //Setup the dropdownlist by using a function. This is more pratical if you have several list that needs the same settings.
  //customize(ports); 
  
  //Toggles
  f = createFont("impact", 12);
  textFont(f);
  
  controlP5.setControlFont(f);
  // create a toggle
  controlP5.addToggle("toggleValueV")
     .setPosition(13+260,13)
     .setState(true)
     .setSize(26,26)
     .setColorActive(color(NButton3)) //couleur cliqué
     .setColorBackground(color(NButton))// couleur pas cliqué
     .setColorForeground(color(NButton2)) // couleur survol de sourie
     .captionLabel().setVisible(false); //cacher le descriptif
     
   controlP5.addToggle("toggleValueR")
     .setPosition(13+33+260,13)
     .setSize(26,26)
     .setState(true)
     .setColorActive(color(NButton3)) //couleur cliqué
     .setColorBackground(color(NButton))// couleur pas cliqué
     .setColorForeground(color(NButton2)) // couleur survol de sourie
     .captionLabel().setVisible(false); //cacher le descriptif
     
    controlP5.addToggle("toggleValueB")
     .setPosition(13+33+33+260,13)
     .setSize(26,26)
     .setState(true)
     .setColorActive(color(NButton3)) //couleur cliqué
     .setColorBackground(color(NButton))// couleur pas cliqué
     .setColorForeground(color(NButton2)) // couleur survol de sourie
     .captionLabel().setVisible(false); //cacher le descriptif
     
    controlP5.addToggle("toggleValueY")
     .setPosition(13+33+33+33+260,13)
     .setSize(26,26)
     .setState(true)
     .setColorActive(color(NButton3)) //couleur cliqué
     .setColorBackground(color(NButton))// couleur pas cliqué
     .setColorForeground(color(NButton2)) // couleur survol de sourie
     .captionLabel().setVisible(false); //cacher le descriptif
     
     controlP5.addToggle("toggleValueVi")
     .setPosition(13+33+33+33+33+260,13)
     .setSize(26,26)
     .setState(true)
     .setColorActive(color(NButton3)) //couleur cliqué
     .setColorBackground(color(NButton))// couleur pas cliqué
     .setColorForeground(color(NButton2)) // couleur survol de sourie
     .captionLabel().setVisible(false); //cacher le descriptif
     
     controlP5.addToggle("toggleValueC")
     .setPosition(13+33+33+33+33+33+260,13)
     .setSize(26,26)
     .setState(true)
     .setColorActive(color(NButton3)) //couleur cliqué
     .setColorBackground(color(NButton))// couleur pas cliqué
     .setColorForeground(color(NButton2)) // couleur survol de sourie
     .captionLabel().setVisible(false) //cacher le descriptif
     ;
       // create a DropdownList
     ports = controlP5.addDropdownList("myList-d1")
          .setPosition(11, 34+8);
     customize(ports); 
           
  controlP5.addButton("new")
     .setValue(128)
     .setPosition(WindowW-163,8+1)
     .setImages(loadImage("new_button-01.png"),loadImage("new_button-02.png"),loadImage("new_button-03.png"))
     .updateSize()
     ;
         
 buttonLiveMode= controlP5.addButton("LiveMode")
   /*  .setValue(128)*/
     .setPosition(494,8)
     .setImages(loadImage("read_button-01.png"),loadImage("read_button-02.png"),loadImage("read_button-03.png"))
     .setSwitch(true)
     .updateSize()
     ;
     
   buttonReadMode=controlP5.addButton("ReadMode")
    // .setValue(128)
     .setPosition(638,8)
     .setImages(loadImage("Co-disconnected-01.png"),loadImage("Co-disconnected-02.png"),loadImage("Co-disconnected-03.png"))
     .setSwitch(true)
     .updateSize()
     ;  
  
  controlP5.addButton("SaveToFile")
     //.setValue(128)
     .setSwitch(true)
     .setPosition(WindowW-124,8+1)
     .setImages(loadImage("save_button-01.png"),loadImage("save_button-02.png"),loadImage("save_button-03.png"))
     .updateSize()
     ;
   // create a group to store the messageBox elements
  messageBox = controlP5.addGroup("messageBox",350,250,400);
  messageBox.setBackgroundHeight(200);
  messageBox.setBackgroundColor(color(200));
  messageBox.hideBar();   
  messageBox.hide();
  bDownload=controlP5.addButton("bD")
     .setPosition(150,10)
     .setImages(loadImage("Download_Button-01.png"),loadImage("Download_Button-02.png"),loadImage("Download_Button-03.png"))
     .updateSize()
     ;
  bDownload.moveTo(messageBox);
  slDownload=controlP5.addSlider("sliderValue",0,100,50,150,300,20);
  slDownload.captionLabel().setVisible(false);
  slDownload.setColorActive(NButton);
  slDownload.setColorBackground(Shadow);
  slDownload.setColorForeground(NButton);
  slDownload.moveTo(messageBox);
  bMessageBoxOK=controlP5.addButton("OK");
 
  bMessageBoxOK.setPosition(180,180);
  bMessageBoxOK.setColorActive(NButton);
  bMessageBoxOK.setColorBackground(Shadow);
  bMessageBoxOK.setColorForeground(NButton);
  bMessageBoxOK.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  bMessageBoxOK.setVisible(false);
  bMessageBoxOK.moveTo(messageBox); 
  /*   .setPosition(0,10)
     .setSize(200,16)
     .setRange(0,100)
     .setColorBackground(Shadow)
     .setColorForeground(NButton)
     .setColorActive(NButton)
     .captionLabel().setVisible(false)
     ;*/
 //messagebox save 1
  messageBoxSave1 = controlP5.addGroup("messageBoxSave1",350,250,400);
  messageBoxSave1.setBackgroundHeight(200);
  messageBoxSave1.setBackgroundColor(color(200));
  messageBoxSave1.hideBar();   
  messageBoxSave1.hide();
  lMessageBoxSave1= controlP5.addTextlabel("labelsave1")
                    .setText("Save File")
                    .setPosition(150,20)
                    .setFont(createFont("impact", 20))
                    ;
  lMessageBoxSave1.moveTo(messageBoxSave1);    
  fileName1= controlP5.addTextfield("input")
     .setPosition(100,70)
     .setSize(200,25)
     .setColorActive(NButton)
     .setColorBackground(Shadow)
     .setColorCursor(255)
     .setFont(createFont("impact",18))
     .setFocus(true)
     .setColor(NButton)
     .setCaptionLabel(" ")
     ;
   fileName1.moveTo(messageBoxSave1);         
   bMessageSaveOK=controlP5.addButton("bSaveOK");
   bMessageSaveOK.setCaptionLabel("Save");
   bMessageSaveOK.setPosition(180,140);
   bMessageSaveOK.setSize(100,30);
   bMessageSaveOK.setColorActive(NButton);
   bMessageSaveOK.setColorBackground(Shadow);
   bMessageSaveOK.setColorForeground(NButton);
   bMessageSaveOK.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
   bMessageSaveOK.moveTo(messageBoxSave1); 
  
 //message box error 1 
  messageBoxError1 = controlP5.addGroup("messageBoxError1",350,250,400);
  messageBoxError1.setBackgroundHeight(200);
  messageBoxError1.setBackgroundColor(color(200));
  messageBoxError1.hideBar();   
  messageBoxError1.hide(); 
  lMessageBoxError1= controlP5.addTextlabel("label")
                    .setText("Error 001: No port selected !")
                    .setPosition(100,20)
                    .setFont(createFont("impact", 20))
                    ;
  lMessageBoxError1.moveTo(messageBoxError1);                  
  bMessageBoxError1OK=controlP5.addButton("bError1OK");
  bMessageBoxError1OK.setCaptionLabel("OK");
  bMessageBoxError1OK.setSize(100,30);
  bMessageBoxError1OK.setPosition(150,150);
  bMessageBoxError1OK.setColorActive(NButton);
  bMessageBoxError1OK.setColorBackground(Shadow);
  bMessageBoxError1OK.setColorForeground(NButton);
  bMessageBoxError1OK.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  bMessageBoxError1OK.moveTo(messageBoxError1); 
  
  //message box warning 1: unsaved changes 
  messageBoxWarning1 = controlP5.addGroup("messageBoxWarning1",350,250,400);
  messageBoxWarning1.setBackgroundHeight(200);
  messageBoxWarning1.setBackgroundColor(color(200));
  messageBoxWarning1.hideBar();   
  messageBoxWarning1.hide(); 
  lMessageBoxWarning1= controlP5.addTextlabel("label00")
                    .setText("Warning : Unsaved data will be lost !")
                    .setPosition(100,20)
                    .setFont(createFont("impact", 20))
                    ;
  lMessageBoxWarning1.moveTo(messageBoxWarning1);                  
  bMessageBoxWarning1OK=controlP5.addButton("bWarning1OK");
  bMessageBoxWarning1OK.setCaptionLabel("OK");
  bMessageBoxWarning1OK.setSize(100,30);
  bMessageBoxWarning1OK.setPosition(100,150);
  bMessageBoxWarning1OK.setColorActive(NButton);
  bMessageBoxWarning1OK.setColorBackground(Shadow);
  bMessageBoxWarning1OK.setColorForeground(NButton);
  bMessageBoxWarning1OK.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  bMessageBoxWarning1OK.moveTo(messageBoxWarning1);
  //button cancel
  bMessageBoxWarning1CANCEL=controlP5.addButton("bWarning1CANCEL");
  bMessageBoxWarning1CANCEL.setCaptionLabel("CANCEL");
  bMessageBoxWarning1CANCEL.setSize(100,30);
  bMessageBoxWarning1CANCEL.setPosition(210,150);
  bMessageBoxWarning1CANCEL.setColorActive(NButton);
  bMessageBoxWarning1CANCEL.setColorBackground(Shadow);
  bMessageBoxWarning1CANCEL.setColorForeground(NButton);
  bMessageBoxWarning1CANCEL.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  bMessageBoxWarning1CANCEL.moveTo(messageBoxWarning1);
}

void drawmenuBoxes()
  {
    // scroll button box
  smooth();
  stroke (255, 50, 50);
  strokeWeight (2);
  fill (130);
  rect( 240, 430, 190, 169);
  fill (200);
  rect(240, 580, 105, 18);
  fill (0);
  text ("scroll button box", 245, 593);
  stroke (0);
    rect (260, 450, 30, 20);// scroll button frames
    rect (260, 500, 40, 20);
    rect (260, 550, 50, 20);
    rect (360, 450, 30, 20);
    rect (360, 500, 40, 20);
    rect (360, 550, 50, 20);
    //draw toggle box
    smooth();
    stroke (50, 200, 50);
    strokeWeight (2);
    fill (130);
    rect(20, 480, 200, 119);
    fill (200);
    rect(20, 580, 110, 18);
    fill (0);
    text ("draw toggle box", 25, 593);
    stroke (0);
    rect (40,500,20,20);// draw toggle frames
    rect (90,500,20,20);
    rect (140,500,20,20);
    rect (140,550,20,20);
    
    //zoom button box
    smooth();
    stroke (50, 50, 255);
    strokeWeight (2);
    fill (130);
    rect (450, 480, 145, 119);
    fill (200);
    rect (450, 580, 65, 18);
    fill (0);
    text ("zoom box", 455, 593);
    stroke (0);
    rect (470, 500, 40, 20);//zoom button frames
    rect (470, 552, 45, 20);
    rect (530, 500, 40, 20);
    rect (530, 552, 45, 20);
  }
void drawgraphLegends()
  {
  // This draws the graph key info
  strokeWeight(1.5);
 // stroke(255, 0, 0);     line(20, 420, 35, 420);//axes legend
 // stroke(0, 255, 0);     line(20, 440, 35, 440);
 // stroke(0, 0, 255);     line(20, 460, 35, 460);
  stroke(0, 0, 0);       line(700, 450, 700, 465);//timer legend
  stroke(255, 0, 0);     line(700, 480, 700, 495);
  stroke(0, 0, 255);     line(700, 510, 700, 525);
  stroke(0, 255, 0);     line(700, 540, 700, 555);   
  fill(0, 0, 0);
  text("xAcc.", 22, 430);
  text("yAcc.",22, 450);
  text("zAcc.", 22, 470);
  text("xGyro.", 72, 430);
  text("yGyro.",72, 450);
  text("zGyro.", 72, 470);
  text("1s checkpoint", 704, 460);
  text("10s checkpoint", 704, 490);
  text("1min checkpoint", 704, 520);
  text("5min checkpoint", 704, 550);
  }
void a(boolean theFlag){
  if(theFlag==true){
  DisplayAccX=true;
  }
  else if(theFlag==false){   
  DisplayAccX=false;
  }
}
void b(boolean theFlag){
  if(theFlag==true){
  DisplayAccY=true;
  }
  else if(theFlag==false){   
  DisplayAccY=false;
  }
}
void c(boolean theFlag){
  if(theFlag==true){
  DisplayAccZ=true;
  }
  else if(theFlag==false){   
  DisplayAccZ=false;
  }
}
void d(boolean theFlag){
  if(theFlag==true){
  DisplayGyroX=true;
  }
  else if(theFlag==false){   
  DisplayGyroX=false;
  }
}
void e(boolean theFlag){
  if(theFlag==true){
  DisplayGyroY=true;
  }
  else if(theFlag==false){   
  DisplayGyroY=false;
  }
}
void f(boolean theFlag){
  if(theFlag==true){
  DisplayGyroZ=true;
  }
  else if(theFlag==false){   
  DisplayGyroZ=false;
  }
}
void DrawGraphAxes(){
 stroke (0);
 line(10,acc_VerticalOrigin,1024-10,acc_VerticalOrigin);
 line(10,gyro_VerticalOrigin,1024-10,gyro_VerticalOrigin);
}
void DrawGraphBoxes() {
  // ecran blanc 
  fill(255);
  rect(8 ,8+36 , WindowW-8-11 ,300 );
  // ecran blanc 2  
  noStroke();
  fill(255);
  rect(8 ,8+36+8+300 , WindowW-8-11 ,300 );
}
void DrawCheckBoxes() {
  // bande noire 
  noStroke();
  fill(50,53,54);
  rect(8 ,8 , 3+33+33+33+33+33+33+260 ,36 );
  // fond bouton vert
  noStroke();
  fill(100,188,111);
  rect(11+260 ,11 , 30 ,30 ); 
  // fond bouton rouge
  noStroke();
  fill(R1);
  rect(11+33+260 ,11 , 30 ,30 ); 
  // fond bouton bleu
  noStroke();
  fill(B1);
  rect(11+33+33+260 ,11 , 30 ,30 );
  // fond bouton jaune
  noStroke();
  fill(Y1);
  rect(11+33+33+33+260 ,11 , 30 ,30 );
  // fond bouton violet
  noStroke();
  fill(Vi1);
  rect(11+33+33+33+33+260 ,11 , 30 ,30 );
  // fond bouton cyan
  noStroke();
  fill(C1);
  rect(11+33+33+33+33+33+260 ,11 , 30 ,30 );
  //push inside of the stack
 /* pushMatrix();
  if(toggleValueV==true) {
    fill(V1);
  } else {
    fill(200);
  }
  translate(200,200);
  rect(0,0,100,100);
  popMatrix();
  pushMatrix();
  if(toggleValueR==true) {
    fill(R1);
  } else {
    fill(200);
  }
  translate(100,200);
  rect(0,0,100,100);
  popMatrix();
  pushMatrix();
  
  if(toggleValueB==true) {
    fill(B1);
  } else {
    fill(200);
  }
  translate(300,200);
  rect(0,0,100,100);
  popMatrix();*/
}
void DrawShadows() {
  
  // bande noire ombre 
  noStroke();
  fill(Shadow);
  rect(8+8 ,8+8 , 3+33+33+33+33+33+33+260 ,36 );
  
  //carré boutons blancs onbre
  fill(Shadow);
  rect(WindowW-11-36+8,8+36,36,8);
  
  // ecran blanc ombre  
  noStroke();
  fill(Shadow);
  rect(8+8 ,8+36+8 , WindowW-8-11 ,300 );
  
  // ecran blanc 2 ombre
    noStroke();
  fill(Shadow);
  rect(8+8 ,8+36+8+8+300 , WindowW-8-11 ,300 );
}
/*
Modes 
*/
void LiveMode() {
  boolean theFlag=buttonLiveMode.getBooleanValue();
  if(theFlag==true && Comselected) {
     println("livemode toggle");
     myPort = new Serial(this, comList[Ss],comSpeed);
     serialSet = true;
     myPort.write('A');
     /*println(Serial.list());
     String portName = Serial.list()[1];
     myPort = new Serial(this, portName,38400);*/
     Mode=1;
     } 
  else if(theFlag==false && serialSet==true){
     println("close the port");
     myPort.write('q');
     //myPort.stop();
     Mode=3;
     }
  else if(theFlag==true && !Comselected){
    showMessageBoxError1=true;
    buttonLiveMode.setOff();
    println("unknown event");
    //toggleLiveMode.setState(false);
    Mode=0;
    }
}
void ReadMode() {
  boolean theFlag=buttonReadMode.getBooleanValue();
  if(theFlag==true)
    {  
       println("on");
       showMessageBox=1;
    }
  else if(theFlag==false) 
  {
    println("from redmode button");
    showMessageBox=0;
  }
  /*if(theFlag==true && Comselected) {
     println("read mode");
     myPort = new Serial(this, comList[Ss],comSpeed);
     serialSet = true;
      myPort.write('A');
     //myPort = new Serial(this, theport[Ss],comSpeed);
     /*println("a toggle event true");
     println(Serial.list());
     String portName = Serial.list()[4];
     myPort = new Serial(this, portName,38400);*/
  /*   Mode=2;
     } 
   else {
     println("stop read mode");
     Mode=1;
    }*/
  
}
void bD(int theValue) {
  if(Comselected) {
     println("read mode");
     myPort = new Serial(this, comList[Ss],comSpeed);
     serialSet = true;
     myPort.write('A');
     //myPort = new Serial(this, theport[Ss],comSpeed);
     /*println("a toggle event true");
     println(Serial.list());
     String portName = Serial.list()[4];
     myPort = new Serial(this, portName,38400);*/
     Mode=7;
     } 
  /*showMessageBox=0;
  /*slDownload.setValue(100);*/
  //messageBox.hide();
  }
void bSaveOK()
  {
  println(fileName1.getText());
  fileName="data/"+fileName1.getText()+".csv";
  dataXYZ = new String[currentPos];
  for (int i = 0; i < currentPos; i ++ ) {
    dataXYZ[i] = dataX[i] + " ; " + dataY[i] + " ; " +dataZ[i]+" ; "+dataGyroX[i]+" ; "+dataGyroY[i]+" ; "+dataGyroZ[i];
  }
  // Save to File
  // The same file is overwritten by adding the data folder path to saveStrings().
  saveStrings( fileName, dataXYZ);
  //bMessageSaveOK.setCaptionLabel("Ok");
   showMessageBoxSave1=false;
  }
  
void SaveToFile() {
  showMessageBoxSave1=true;
  /* boolean theFlag=buttonReadMode.getBooleanValue();
  
  if(theFlag==true) {
  dataXYZ = new String[currentPos];
  for (int i = 0; i < currentPos; i ++ ) {
    dataXYZ[i] = dataX[i] + " ; " + dataY[i] + " ; " +dataZ[i];
  }
  // Save to File
  // The same file is overwritten by adding the data folder path to saveStrings().
  saveStrings("data/data.csv", dataXYZ);
  } 
  else{
     println("data loaded");
    // Mode=1;
    }*/
}
void DrawFromFile(boolean theFlag) {
  if(theFlag==true) {
     file = loadStrings ("data/databemol.csv");//données sauvegardées
  float[] coord;
  for (int i = 0; i < file.length ; i++) {//i va de 0 au nombre
   //de lignes du tableau excel
  float[] toto = float (split (file [i], ";"));
   println (toto[0]); //x
   dataX [i]= toto [0];
   println (toto[1]); //y
   dataY [i]= toto [1];
   println (toto[2]); //Z
   dataZ [i]= toto [2];
  
 } 
 Mode=3;
 println ("mode=3");
 endPos= file.length;
 
  }
 
}


void draw() {
  //messageBox progress bar
  if(showMessageBox==1) messageBox.show();
  else messageBox.hide();
  //messagebox com not selected
  if(showMessageBoxError1) messageBoxError1.show();
  else messageBoxError1.hide();
  if(showMessageBoxSave1) messageBoxSave1.show();
  else messageBoxSave1.hide();
  if(showMessageBoxWarning1) messageBoxWarning1.show();
  else messageBoxWarning1.hide();
 //0 cf.setLocation(800, 400);
  //if(Mode==1) cf.hide();
  //else cf.show();
  background(170,171,173);
// strokeWeight(1);
  //drawmenuBoxes();
 DrawShadows(); 
 DrawGraphBoxes();
 DrawCheckBoxes();
 if(DisplayGraphAxes) DrawGraphAxes();
 // drawgraphBox(); 
  //drawgraphLegends();
 // fill (132);
 // rect (11, 190, 799, 41);// bande de tracé approximatif des axes horizontaux ou approchants.
 // stroke (0);
 // line (11, 210, 809, 212);
  //la ligne noire centrale repère la valeur moyenne mesurée à l'horizontale (à faire plus précisément avec niveau à bulle)
  // CETTE VALEUR EST LE G_FORCE 0. 210 pixels. REFERENCE.
  //text ("Horizontal approx", 650, 176);
//noStroke();
//  fill (102);
//  rect (11, 62, 799, 21);// bande de tracé de l'axe vertical en g-force 1g positive
  //(flèche du device vers le haut pour x et z et vers le bas pour y).
 // text ("vertical 1g_force+ approx", 650, 46);
//  rect (11, 329, 799, 21);// bande de tracé de l'axe vertical en g force 1g négative
  //(flèche du device vers le bas en x et z et vers le haut en y).
 // text ("vertical 1g_force- approx", 650, 313);
//stroke (0);
//  line (11, 73, 809, 73);
//  line (11, 339, 809, 340);
//strokeWeight(1.5);
 // stroke(255, 0, 0);
 if(DisplayAccX)  drawXLine();
 if(DisplayAccY) drawYLine();
 if(DisplayAccZ) drawZLine();
 if(DisplayGyroX) drawGyroXLine();
 if(DisplayGyroY) drawGyroYLine();
 if(DisplayGyroZ) drawGyroZLine();
 // g_graph.drawLine(1);
 // stroke(0, 0, 255);
 // g_graph.drawLine(2);
 /* stroke(255, 255, 0);
  g_graph.drawLine(g_vRef, 0, 1024);
  stroke(255, 0, 255);
  g_graph.drawLine(g_xRate, 0, 1024);
  stroke(0, 255, 255);
  g_graph.drawLine(g_yRate, 0, 1024);*/
  //background(255);
//hint(ENABLE_DEPTH_TEST);
//fill(0);
//rect(500,300,100,100);
//hint(DISABLE_DEPTH_TEST);
/* // pushMatrix();
  if(messageBox.isVisible()) {
    background(128);
  } else {
    background(0);
    fill(255);
   // text(messageBoxString,20,height-40);
  }
  
  //translate(width/2,height/2,mouseX);
  //rotateY(t+=0.1);
  //fill(255);
  //rect(-50,-50,100,100);
  //popMatrix();
  hint(DISABLE_DEPTH_TEST);*/
}
 void drawXLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    int tmp = 1;
    int tmp10s = 1;
    int tmp1min = 1;
    int tmp5min = 1;
    int j = 0;
    //println ("start ="+startPos);
    //println ("end = "+endPos);
    for(int i=startPos; i<endPos-1; i++)
    {
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = acc_VerticalOrigin-(dataX[i])*graphMultY;//old dataX[i]+1.5
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = acc_VerticalOrigin-(dataX[i+1])*graphMultY;//old dataX[i]+1.5
      tmp= i%16;
      tmp10s=i%160;
      tmp1min=i%960;
      tmp5min=i%4800;//le modulo (%) fait que lorsque i est un multiple
      //de 16, le reste de la division vaut 0. Donc quand tmp
      //=0 on est à un multiple de 16 donc sur un point-seconde.
      strokeWeight (1);
      stroke (0, 255, 0);
      line(x0, y0, x1, y1);
     /*stroke (0);
      strokeWeight (1);
      point (x0, y0);*/
      }
   }
     
 
  void drawYLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = acc_VerticalOrigin-(dataY[i])*graphMultY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = acc_VerticalOrigin-(dataY[i+1])*graphMultY;
      stroke (255, 0, 0);
      strokeWeight (1);
      line(x0, y0, x1, y1);
     /* stroke (0);
      strokeWeight (1);
      point (x0, y0);*/
      }
  }
void drawZLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    int tmp = 0;
   
    for(int i=startPos; i<endPos-1; i++)
    {
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = acc_VerticalOrigin-(dataZ[i])*graphMultY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = acc_VerticalOrigin-(dataZ[i+1])*graphMultY;
      stroke (0, 0, 255);
      strokeWeight (1);
      line(x0, y0, x1, y1);
      /*stroke (0);
      strokeWeight (1);
      point (x0, y0);*/
    }
 }
void drawGyroXLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = gyro_VerticalOrigin-(dataGyroX[i]+1.5)*graphMultGyroY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = gyro_VerticalOrigin-(dataGyroX[i+1]+1.5)*graphMultGyroY;
      strokeWeight (1);
      stroke (0, 255, 255);
      line(x0, y0, x1, y1);
     /* stroke (0);
      strokeWeight (1);
      point (x0, y0);*/
      }
 }
void drawGyroYLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = gyro_VerticalOrigin-(dataGyroY[i]+1.5)*graphMultGyroY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = gyro_VerticalOrigin-(dataGyroY[i+1]+1.5)*graphMultGyroY;
      stroke (0, 102, 102);
       strokeWeight (1);
      line(x0, y0, x1, y1);
       
      /*stroke (0);
      strokeWeight (1);
      point (x0, y0);*/
      }
 }
void drawGyroZLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = gyro_VerticalOrigin-(dataGyroZ[i]+1.5)*graphMultGyroY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = gyro_VerticalOrigin-(dataGyroZ[i+1]+1.5)*graphMultGyroY;
      stroke (102, 102, 255);
      strokeWeight (1);
      line(x0, y0, x1, y1);
     /* stroke (0);
      strokeWeight (1);
      point (x0, y0);*/
      }
 } 
//gb_X and gb_Y coordinates bottomleft graphbox
void drawgraphBox(){
   stroke(0, 0, 0);
   //xbottom ybottom, width, height
   rect(10,10,800,400);
}
void serialEvent(Serial p) {
 
  if(firstContact==false && Mode==1){
    int inByte = myPort.read();
    if (inByte == 'A') { 
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      println("Contact!");
      myPort.write('l');       // ask for more
     
    } 
    else  println("Something wrong");
  }
 else if(firstContact==false && Mode==2){
    println("contact0");
    int inByte = myPort.read();
    if (inByte == 'A') { 
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('r');       // ask for more
      println("contact!");
    } 
    else  println("Something wrong");
 }
   //get the status of the memory
   else if(firstContact==false && Mode==7){
    println("contact0");
    int inByte = myPort.read();
    if (inByte == 'A') { 
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('t');       // ask for more
      println("contact!");
    } 
    else  println("Something wrong");
   }
  else if(firstContact==true && (Mode==1 || Mode==2)){
  // get message till line break (ASCII > 13)
  String message = myPort.readStringUntil(13);
  //println(message);
  float value;
  if(message != null){
    value = float(message);
    if(value<=65535 && value>=-65535){
    if(verbose_value==1) println(value);
    //remplir les X
    if(serialCount==0){
   /* print("ax: ");
    println(value);*/
    value = value*(acc_range/65535);
    dataX[currentPos]=value;
   // println(value);
   // println(serialCount);
    serialCount++;
    }
    //remplir les Y
    else if(serialCount==1){
    /*  print("ay: ");
      println(value);*/
      value = value*(acc_range/65535);
      dataY[currentPos]=value;
    //println(value);
    //println(serialCount);
    serialCount++; 
    }
    //remplir les Z
    else if(serialCount==2){
    /*  print("az: ");
      println(value);*/
      value = value*(acc_range/65535);
      dataZ[currentPos]=value;
   // println(value);
    //println(serialCount);
    serialCount++; 
    /*if (currentPos>200){
    startPos=startPos+1;
    endPos=endPos+1;
    }
    else endPos=currentPos;
    currentPos++;*/
    }
   else if(serialCount==3){
    // println(value);
     /*print("gx: ");
     println(value);*/
     value = value*(gyro_range/65535);
     //println(value);
     dataGyroX[currentPos]=value;
    // println(value);
     serialCount++; 
     }
   else if(serialCount==4) {
   /*  print("gy: ");
    println(value);*/
     value = value*(gyro_range/65535);
     dataGyroY[currentPos]=value;
     //println(value);
     serialCount++;
     }
   else if(serialCount==5){
    /* print("gz: ");
     println(value);*/
     value = value*(gyro_range/65535);
     dataGyroZ[currentPos]=value;
     //println(value);
     serialCount++;
     }  
   if(serialCount==6){
     serialCount=0;
       if (currentPos>max_x_point){
    startPos=startPos+1;
    endPos=endPos+1;
    }
    else endPos=currentPos;
    currentPos++;
    if(Mode==2) {
    //println((currentPos*100)/point_nb + "%");
    slDownload.setValue((currentPos*100)/point_nb);  
    if(currentPos>=point_nb)  bMessageBoxOK.setVisible(true);
    }
    // println("+1");
     //myPort.write('A');
    }
  }
  else println("error");
 }
 
 }
 //mode 7: get the status of the memory
  else if(firstContact==true && Mode==7){
  // get message till line break (ASCII > 13)
  String message = myPort.readStringUntil(13);
  float page_nbf=0;
  int page_nb=0;
 // println(message);
  if(message != null){
   page_nbf = float(message);
    if( page_nbf>=0 &&  page_nbf<=4097)
      {
    println(message);
    page_nbf = float(message);
    //println(page_nb);
    page_nb=int(page_nbf);
    println(page_nb);
    point_nb=(page_nb*264)/6;
    println(point_nb);
    measurment_time=point_nb/sampling_rate;
    println(measurment_time + " seconds");
     Mode=2;
    myPort.write('r');
      }
   //
    }    
  }
 //////////////////////////////
   else if(firstContact==true && Mode==5){
  // get message till line break (ASCII > 13)
  String message = myPort.readStringUntil(13);
  float value;
  if(message != null){
    value = float(message);
    value = value*0.047;
    //remplir les X
    if(serialCount==0){
      dataX[currentPos]=value;
      println ("X="+ dataX[currentPos]);
      //si >1.5 sortir car fini
      if(value>1.5) 
      {
        Mode=3;
      }
      else 
        serialCount++; 
    }
     //remplir les Y
    else if(serialCount==1){
    dataY[currentPos]=value;
    println ("Y="+ dataY[currentPos]);
    serialCount++; 
    }
     //remplir les Z
    else if(serialCount==2){
    dataZ[currentPos]=value;
    println ("Z="+ dataZ[currentPos]);
    serialCount++;
    currentPos++;
    endPos++;
    }
   if(serialCount==3){
     serialCount=0;
    }
  }
 }//
}
void fwd1 (){ // interrupteur lecture lente vers la droite pas de 1
  if (Mode == 3 || Mode==2) {
    startPos = startPos + 1;
    endPos = endPos + 1;
    println ("startPos = " + startPos);
    println ("endPos = " + endPos);
  }
}
void ffwd10 () { // interrupteur lecture rapide vers la droite pas de 10
  if (Mode == 3 || Mode==2) {
    startPos = startPos + 10;
    endPos = endPos + 10;
    println ("startPos = " + startPos);
    println ("endPos = " + endPos);
  }
}
void fffwd100 () { // interrupteur lecture rapide vers la droite pas de 10
  if (Mode == 3 || Mode==2) {
    startPos = startPos + 100;
    endPos = endPos + 100;
    println ("startPos = " + startPos);
    println ("endPos = " + endPos);
  }
}
void rwd1 () { // interrupteur lecture lente vers la gauche pas de 1
  if (Mode == 3 || Mode==2 ){
    if (startPos > 1){
  startPos = startPos - 1;
  endPos = endPos - 1;
  println ("startPos =" + startPos);
  println ("endPos =" + endPos);
    }
  else startPos = 0;
  }
}
void rrwd10 () { // interrupteur lecture rapide vers la gauche pas de 10
if (Mode == 3 || Mode==2) {
  if (startPos > 10){
  startPos = startPos - 10;
  endPos = endPos - 10;
  }
  else startPos = 10;
  println ("startPos =" + startPos);
  println ("endPos =" + endPos);
}
}
void rrrwd100 () { // interrupteur lecture rapide vers la gauche pas de 10
if (Mode == 3 || Mode==2) {
  if (startPos > 100){
  startPos = startPos - 100;
  endPos = endPos - 100;
  }
  else startPos = 100;
  println ("startPos =" + startPos);
  println ("endPos =" + endPos);
}
}

void zoominx() { // zoom in en x *2
if (Mode == 3){
  graphMultX = graphMultX*2;
  if (graphMultX == 4) println ("basic x-scale recovered");
}
}

void zoomoutx() { // zoom out en x /2
if (Mode == 3){
  graphMultX = graphMultX/2;
  if (graphMultX == 4) println ("basic x-scale recovered");
}
}

void zoominy() { // zoom in en y + 10
if (Mode == 3){
  graphMultY = graphMultY + 10;
  if (graphMultY == 133) println ("basic y-scale recovered"); 
}
}

void zoomouty() { // zoom out en x -10
if (Mode == 3){
  graphMultY = graphMultY - 10;
  if (graphMultY == 133) println ("basic y-scale recovered");
}
}
void toggleValueV(boolean theFlag) {
  DisplayAccX=theFlag;
  }
void toggleValueR(boolean theFlag){
    DisplayAccY=theFlag;
  } 
void toggleValueB(boolean theFlag){
    DisplayAccZ=theFlag;
  } 
void toggleValueY(boolean theFlag){
    DisplayGyroX=theFlag;
  } 
void toggleValueVi(boolean theFlag){
    DisplayGyroY=theFlag;
  } 
void toggleValueC(boolean theFlag){
    DisplayGyroZ=theFlag;
  }
void OK(){
  println("ok");
  showMessageBox=0;
}
void bError1OK(){
showMessageBoxError1=false;
}
void bWarning1CANCEL(){
showMessageBoxWarning1=false;
}
// function buttonOK will be triggered when pressing
// the OK button of the messageBox.
/*void buttonOK(int theValue) {
  println("a button event from button OK.");
 /* messageBoxString = ((Textfield)cp5.controller("inputbox")).getText();
  messageBoxResult = theValue;*/
/*  showMessageBox=0;
  //messageBox.hide();
}*/
/*void bD(int theValue) {
  println("a button event from button OK.");
  showMessageBox=0;
  slDownload.setValue(100);
  //messageBox.hide();
  }*/
 /*void mousePressed(){
     if (mouseY < 10){
     println ("x="+ mouseX);
     println ("y="+ mouseY);
   }
   else if (mouseY >= 10 && mouseY <= 210){
     println ("x="+ mouseX);
     println ("y="+ mouseY);
     println ("acc_value=" + (210-mouseY)*0.0075);
     
   }
   else if (mouseY >= 210 && mouseY <= 410) {
      println ("x="+ mouseX);
     println ("y="+ mouseY);
     println ("acc_value=" + (210-mouseY)*0.0075);
   }
   else if (mouseY > 410) {
      println ("x="+ mouseX);
     println ("y="+ mouseY);
   }
   }*/
/*
Serial Port selection
*/

//The dropdown list returns the data in a way, that i dont fully understand, again mokey see monkey do. However once inside the two loops, the value (a float) can be achive via the used line ;).
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) 
  {
    //Store the value of which box was selected, we will use this to acces a string (char array).
    float S = theEvent.group().value();
    //Since the list returns a float, we need to convert it to an int. For that we us the int() function.
    Ss = int(S);
    //With this code, its a one time setup, so we state that the selection of port has been done. You could modify the code to stop the serial connection and establish a new one.
    Comselected = true;
    //println("COM selected");
  }
}
// the dropdown part
void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(30);
  ddl.setBarHeight(30);
  ddl.setWidth(250);
  ddl.captionLabel().set("Choose a port");
  ddl.captionLabel().style().marginTop = 10;
  ddl.captionLabel().style().marginLeft = 10;
  ddl.valueLabel().style().marginTop = 3;
  /*  for (int i=0;i<6;i++) {
    ddl.addItem("port "+i, i);
    }*/
  //ddl.scroll(0);
  ddl.setColorBackground(color(50,53,54));
  ddl.setColorForeground(color(90));
  ddl.setColorActive(color(255));
  //Store the Serial ports in the string comList (char array).
  comList = myPort.list();
  //We need to know how many ports there are, to know how many items to add to the list, so we will convert it to a String object (part of a class).
  String comlist = join(comList, ",");
  //We also need how many characters there is in a single port name, we´ll store the chars here for counting later.
  String COMlist = comList[0];
  //Here we count the length of each port name.
  int size2 = COMlist.length();
  //Now we can count how many ports there are, well that is count how many chars there are, so we will divide by the amount of chars per port name.
  int size1 = comlist.length() / size2;
  //println(size1);
  //Now well add the ports to the list, we use a for loop for that. How many items is determined by the value of size1.
  for(int i=0; i< comList.length; i++)
  {
    //println(i);
    //This is the line doing the actual adding of items, we use the current loop we are in to determin what place in the char array to access and what item number to add it as.
    //ddl.addItem(comList[i],i);
    String pn = shortifyPortName(Serial.list()[i], 13);
    if (pn.length() >0 )ddl.addItem(pn,i); 
   // println(comList[i]);
  }
}

// coded by Eberhard Rensch
// Truncates a long port name for better (readable) display in the GUI
String shortifyPortName(String portName, int maxlen)  {
  String shortName = portName;
  if(shortName.startsWith("/dev/")) shortName = shortName.substring(5);  
  if(shortName.startsWith("tty.")) shortName = shortName.substring(4); // get rid off leading tty. part of device name
  if(portName.length()>maxlen) shortName = shortName.substring(0,(maxlen-1)/2) + "~" +shortName.substring(shortName.length()-(maxlen-(maxlen-1)/2));
  if(shortName.startsWith("cu.")) shortName = "";// only collect the corresponding tty. devices
  return shortName;
}
