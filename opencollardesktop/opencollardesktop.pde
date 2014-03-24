
import controlP5.*;
import processing.serial.*;

ControlP5 controlP5;
AccelGyro accelgyro; 

void
setup()
{
    PFont font;

    size(1024,700,JAVA2D); //Window width, window height, ????
    controlP5 = new ControlP5(this);

    font = createFont("impact",12);
    //textFont(createFont(font); //TODO: verify it
    controlP5.setControlFont(font); //Define main font

    serial_handler_init();
    dropdown_setup();    
    WarningMessageBox.warningBox_init(controlP5,color(200),color(0,0,0,180),color(0,70),font);
    accelgyro = new AccelGyro(controlP5);
}

void 
draw()
{
    background(128);
    accelgyro.draw();
}

void controlEvent(ControlEvent e)
{
    println("EVENT");
    if(e.isGroup())
    {
        String group_name = e.getGroup().getName();
        println(group_name);
        int value = int(e.getGroup().value());
        println("value = " + value);
        if(ddlaux_eventHandler(group_name,value)){}
    }
}
