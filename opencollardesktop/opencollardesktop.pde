/*

0.83 -- selection of port
0.84 -- add gyro
*/

import controlP5.*;
ControlP5 controlP5;

import processing.serial.*;

int Mode=0; //1: live// 2: read //3: data chargées

Button buttonfwd1,buttonffwd10, buttonfffwd100, buttonrwd1, buttonrrwd10, buttonrrrwd100,buttonzoominx,buttonzoomoutx,buttonzoominy,buttonzoomouty;
Toggle toggleLiveMode,toggleReadMode,toggleSaveToFile,toggleDrawFromFile,toggleAccX,toggleAccY,toggleAccZ,toggleGyroX,toggleGyroY,toggleGyroZ;

Serial myPort;                       // The serial port
int[] serialInArray = new int[3];    // Where we'll put what we receive                // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller
float[] dataX,dataY,dataZ,dataGyroX, dataGyroY, dataGyroZ;
String[] dataXYZ;
String[] file;
float graphMultX = 4; //graphMultX = gb_width/ max data points 
float graphMultY = 133; //gb heigth/pas63 400/3
float graphMultGyroY = 400/250;

/*
Com settings
*/
int comSpeed=38400;

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

float acc_range=4.0;
float gyro_range=250.0;

void setup() {
  background(200);
  //size(g_winW, g_winH, P2D);
  size(g_winW, g_winH);
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(0x00);
  //set the toggles
  toggleLiveMode= controlP5.addToggle("LiveMode",false,40,500,20,20); toggleLiveMode.setColorActive(color (0,250,0)); toggleLiveMode.setColorBackground (color(255, 0, 0));
  toggleReadMode= controlP5.addToggle("ReadMode",false,90,500,20,20); toggleReadMode.setColorActive(color (0,250,0)); toggleReadMode.setColorBackground (color(255, 0, 0));// déclencheurs live et lecture
  toggleSaveToFile= controlP5.addToggle("SaveToFile",false,140,500,20,20); toggleSaveToFile.setColorActive(color (0,250,0)); toggleSaveToFile.setColorBackground (color(255, 0, 0));
  toggleDrawFromFile= controlP5.addToggle("DrawFromFile", false,140,550,20,20); toggleDrawFromFile.setColorActive (color (250,0,0)); toggleDrawFromFile.setColorBackground (color(0,0,250));//toggle pour redessiner
  
  /*toggle enable curves*/
  toggleAccX= controlP5.addToggle("a",true,10,420,10,10); toggleAccX.setColorActive(color (255,0,0)); toggleAccX.setColorBackground (color(0, 0, 0)); toggleAccX.setLabelVisible(false);
  toggleAccY= controlP5.addToggle("b",true,10,440,10,10); toggleAccY.setColorActive(color (0,255,0)); toggleAccY.setColorBackground (color(0, 0, 0)); toggleAccY.setLabelVisible(false);
  toggleAccZ= controlP5.addToggle("c",true,10,460,10,10); toggleAccZ.setColorActive(color (0,0,255)); toggleAccZ.setColorBackground (color(0, 0, 0)); toggleAccZ.setLabelVisible(false);
  toggleGyroX= controlP5.addToggle("d",true,60,420,10,10); toggleGyroX.setColorActive(color (0,255,255)); toggleGyroX.setColorBackground (color(0, 0, 0)); toggleGyroX.setLabelVisible(false);
  toggleGyroY= controlP5.addToggle("e",true,60,440,10,10); toggleGyroY.setColorActive(color (0,102,102)); toggleGyroY.setColorBackground (color(0, 0, 0)); toggleGyroY.setLabelVisible(false);
  toggleGyroZ= controlP5.addToggle("f",true,60,460,10,10); toggleGyroZ.setColorActive(color (102,102,205)); toggleGyroZ.setColorBackground (color(0, 0, 0)); toggleGyroZ.setLabelVisible(false);
  //buttons forward and reward
  buttonfwd1= controlP5.addButton("fwd1",0, 260, 450, 30, 20); buttonfwd1.setColorActive (color(13, 233, 79)); buttonfwd1.setColorBackground (color(153, 102, 255));
  buttonffwd10= controlP5.addButton("ffwd10",0, 260, 500, 40, 20); buttonffwd10.setColorActive (color(46, 210, 62)); buttonffwd10.setColorBackground (color(153, 51, 204));
  buttonfffwd100= controlP5.addButton("fffwd100",0, 260, 550, 50, 20); buttonfffwd100.setColorActive (color(36, 230, 62)); buttonfffwd100.setColorBackground (color(153, 0, 153));
  buttonrwd1= controlP5.addButton("rwd1",0, 360, 450, 30, 20); buttonrwd1.setColorActive (color(255, 0, 0)); buttonrwd1 .setColorBackground (color(255, 204, 102));
  buttonrrwd10= controlP5.addButton("rrwd10",0, 360, 500, 40, 20); buttonrrwd10.setColorActive (color(255, 0, 0)); buttonrrwd10.setColorBackground (color(255, 153, 51));
  buttonrrrwd100= controlP5.addButton("rrrwd100",0, 360, 550, 50, 20); buttonrrrwd100.setColorActive (color(255, 0, 0)); buttonrrrwd100.setColorBackground (color(255, 105, 0));
  
  //buttons for zooming in and out in x and y patterns
  buttonzoominx= controlP5.addButton("zoominx",0, 470, 500, 40, 20); buttonzoominx.setColorActive (color(255, 0, 0)); buttonzoominx.setColorBackground (color(255, 185, 15));
  buttonzoomoutx= controlP5.addButton("zoomoutx",0, 470, 552, 45, 20); buttonzoomoutx.setColorActive (color(255, 0, 0)); buttonzoomoutx.setColorBackground (color(255, 69, 0));
  buttonzoominy= controlP5.addButton("zoominy",0, 530, 500, 40, 20); buttonzoominy.setColorActive (color(255, 0, 0)); buttonzoominy.setColorBackground (color(202, 255, 112));
  buttonzoomouty= controlP5.addButton("zoomouty",0, 530, 552, 45, 20); buttonzoomouty.setColorActive (color(255, 0, 0)); buttonzoomouty.setColorBackground (color(127, 255, 0));
  
  
  dataX = new float[30000];
  dataY = new float[30000];
  dataZ = new float[30000];
  dataGyroX = new float[30000];
  dataGyroY = new float[30000];
  dataGyroZ = new float[30000];
  
  currentPos=0;
  startPos=0;
  endPos=0;
  //Make a dropdown list calle ports. Lets explain the values: ("name", left margin, top margin, width, height (84 here since the boxes have a height of 20, and theres 1 px between each item so 4 items (or scroll bar).
  ports = controlP5.addDropdownList("list-1",40,570,100,84);
  //Setup the dropdownlist by using a function. This is more pratical if you have several list that needs the same settings.
  customize(ports); 
  
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
/*
Modes 
*/
void LiveMode(boolean theFlag) {
  if(theFlag==true && Comselected) {
     //println("livemode toggle");
     myPort = new Serial(this, comList[Ss],comSpeed);
     serialSet = true;
     myPort.write('A');
     /*
     println(Serial.list());
     String portName = Serial.list()[1];
     myPort = new Serial(this, portName,38400);*/
     Mode=1;
     } 
   else if(theFlag==false && serialSet==true){
     println("close the port");
     myPort.write('q');
     myPort.stop();
     Mode=3;
    }
  else {
    println("unknown event");
    toggleLiveMode.setState(false);
    Mode=3;
    }
}
void ReadMode(boolean theFlag) {
  if(theFlag==true && Comselected) {
     println("read mode");
     myPort = new Serial(this, comList[Ss],comSpeed);
     serialSet = true;
      myPort.write('A');
     //myPort = new Serial(this, theport[Ss],comSpeed);
     /*println("a toggle event true");
     println(Serial.list());
     String portName = Serial.list()[4];
     myPort = new Serial(this, portName,38400);*/
     Mode=2;
     } 
   else{
     println("stop read mode");
     Mode=1;
    }
  
}
void SaveToFile(boolean theFlag) {
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
    }
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
  background(200);
  strokeWeight(1);
  drawmenuBoxes();
  fill(255, 255, 255);
  drawgraphBox(); 
  drawgraphLegends();
  noStroke();
 // fill (132);
 // rect (11, 190, 799, 41);// bande de tracé approximatif des axes horizontaux ou approchants.
 // stroke (0);
 // line (11, 210, 809, 212);
  //la ligne noire centrale repère la valeur moyenne mesurée à l'horizontale (à faire plus précisément avec niveau à bulle)
  // CETTE VALEUR EST LE G_FORCE 0. 210 pixels. REFERENCE.
  //text ("Horizontal approx", 650, 176);
  noStroke();
//  fill (102);
//  rect (11, 62, 799, 21);// bande de tracé de l'axe vertical en g-force 1g positive
  //(flèche du device vers le haut pour x et z et vers le bas pour y).
 // text ("vertical 1g_force+ approx", 650, 46);
//  rect (11, 329, 799, 21);// bande de tracé de l'axe vertical en g force 1g négative
  //(flèche du device vers le bas en x et z et vers le haut en y).
 // text ("vertical 1g_force- approx", 650, 313);
  stroke (0);
//  line (11, 73, 809, 73);
//  line (11, 339, 809, 340);
  strokeWeight(1.5);
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
      float y0 = 410-(dataX[i]+1.5)*graphMultY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = 410-(dataX[i+1]+1.5)*graphMultY;
      tmp= i%16;
      tmp10s=i%160;
      tmp1min=i%960;
      tmp5min=i%4800;//le modulo (%) fait que lorsque i est un multiple
      //de 16, le reste de la division vaut 0. Donc quand tmp
      //=0 on est à un multiple de 16 donc sur un point-seconde.
    
      stroke (255, 0, 0);
      line(x0, y0, x1, y1);
      stroke (0);
      strokeWeight (1);
      point (x0, y0);
      /*if (tmp==0){
         j++;
         //println (j);
         //fill (0,0,0);
         //text (((j-1) + "s"), x0+2, 406);
         stroke (0);
         line (x0, 21, x0, 400);
       } if (tmp10s==0){
         stroke (255, 0, 0);
         line (x0, 21, x0, 400);
       } if (tmp1min==0){
         stroke (0, 0, 255);
         line (x0, 21, x0, 400);
         if (tmp5min==0){
           stroke (0, 255, 0);
           line (x0, 21, x0, 400);
         }
       }*/
      }
   }
     
 
  void drawYLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = 410-(dataY[i]+1.5)*graphMultY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = 410-(dataY[i+1]+1.5)*graphMultY;
      stroke (0, 255, 0);
      line(x0, y0, x1, y1);
      stroke (0);
      strokeWeight (1);
      point (x0, y0);
      }
  }
void drawZLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    int tmp = 0;
   
    for(int i=startPos; i<endPos-1; i++)
    {
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = 410-(dataZ[i]+1.5)*graphMultY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = 410-(dataZ[i+1]+1.5)*graphMultY;
      stroke (0, 0, 255);
      line(x0, y0, x1, y1);
      stroke (0);
      strokeWeight (1);
      point (x0, y0);
    }
 }
void drawGyroXLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = 310-(dataGyroX[i]+1.5)*graphMultGyroY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = 310-(dataGyroX[i+1]+1.5)*graphMultGyroY;
      stroke (0, 255, 255);
      line(x0, y0, x1, y1);
      stroke (0);
      strokeWeight (1);
      point (x0, y0);
      }
 }
void drawGyroYLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = 310-(dataGyroY[i]+1.5)*graphMultGyroY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = 310-(dataGyroY[i+1]+1.5)*graphMultGyroY;
      stroke (0, 102, 102);
      line(x0, y0, x1, y1);
      stroke (0);
      strokeWeight (1);
      point (x0, y0);
      }
 }
void drawGyroZLine(){
    /*float graphMultX = 4; //graphMultX = gb_width/ max data points 
    float graphMultY = 133; //gb heigth/pas63 400/3*/
    for(int i=startPos; i<endPos-1; i++){
      float x0 = (i-startPos)*graphMultX+10;
      float y0 = 310-(dataGyroZ[i]+1.5)*graphMultGyroY;
      float x1 = ((i-startPos)+1)*graphMultX+10;
      float y1 = 310-(dataGyroZ[i+1]+1.5)*graphMultGyroY;
      stroke (102, 102, 255);
      line(x0, y0, x1, y1);
      stroke (0);
      strokeWeight (1);
      point (x0, y0);
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
  else if(firstContact==true && (Mode==1 || Mode==2)){
  // get message till line break (ASCII > 13)
  String message = myPort.readStringUntil(13);
  //println(message);
  float value;
  if(message != null){
    value = float(message);
    if(value<=65535 && value>=-65535){
    println(value);
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
       if (currentPos>200){
    startPos=startPos+1;
    endPos=endPos+1;
    }
    else endPos=currentPos;
    currentPos++;
    
    // println("+1");
     //myPort.write('A');
    }
  }
  else println("error");
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

//here we setup the dropdown list.
void customize(DropdownList ddl) {
  //Set the background color of the list (you wont see this though).
  ddl.setBackgroundColor(color(200));
  //Set the height of each item when the list is opened.
  ddl.setItemHeight(20);
  //Set the height of the bar itself.
  ddl.setBarHeight(15);
  //Set the lable of the bar when nothing is selected.
  ddl.captionLabel().set("Select COM port");
  //Set the top margin of the lable.
  ddl.captionLabel().style().marginTop = 3;
  //Set the left margin of the lable.
  ddl.captionLabel().style().marginLeft = 3;
  //Set the top margin of the value selected.
  ddl.valueLabel().style().marginTop = 3;
  //Store the Serial ports in the string comList (char array).
  comList = myPort.list();
  //We need to know how many ports there are, to know how many items to add to the list, so we will convert it to a String object (part of a class).
/*  String comlist = join(comList, ",");
  //We also need how many characters there is in a single port name, we´ll store the chars here for counting later.
  String COMlist = comList[0];
  //Here we count the length of each port name.
  int size2 = COMlist.length();
  //Now we can count how many ports there are, well that is count how many chars there are, so we will divide by the amount of chars per port name.
  int size1 = comlist.length() / size2;*/
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
  //Set the color of the background of the items and the bar.
 // ddl.setColorBackground(color(60));
  //Set the color of the item your mouse is hovering over.
 // ddl.setColorActive(color(255,128));
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
