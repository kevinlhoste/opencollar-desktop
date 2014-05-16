boolean
    port_selected;
    
Serial myPort;
String[] comList;

DropdownList 
    acce_list,
    gyro_list,
    sampling_list,
    port_list;
    
void
dropdown_setup()
{
    acce_list = controlP5.addDropdownList("acce_list").setPosition(0, 30);
    acce_range_ddl(acce_list);
    gyro_list = controlP5.addDropdownList("gyro_list").setPosition(120, 30);
    gyro_range_ddl(gyro_list);
    sampling_list = controlP5.addDropdownList("sampling_list").setPosition(240,30);
    sampling_ddl(sampling_list);
    port_list = controlP5.addDropdownList("port_list").setPosition(360, 30);
    port_ddl(port_list);
    port_selected = false;
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

void
port_ddl(DropdownList ddl)
{
    ddl.setItemHeight(30); //Height of items in list
    ddl.setBarHeight(30); //Height of the list button
    ddl.setWidth(120); //width of the list
    ddl.captionLabel().set("Serial port"); //text shown in the list button
    ddl.captionLabel().style().marginTop = 5; //distance from the text and the top
    ddl.captionLabel().style().marginLeft = 10; //distance from the text and the left corner
    ddl.valueLabel().style().marginTop = 3; //I don't know what this does

    ddl.setColorBackground(color(50,53,54)); //background color of the list
    ddl.setColorForeground(color(90)); //color when an element of the list is highlighted
    ddl.setColorActive(color(250)); //color when a element is selected (for a brief instant)

    comList = Serial.list(); //receives a list of serial ports
    
    for(int i = 0; i < comList.length; i++)
    {
        String pn = shortifyPortName(comList[i],13);
        if(pn.length() > 0) ddl.addItem(pn,i);
    }
}

void 
acce_range_ddl(DropdownList ddl)
{
    ddl.setItemHeight(30); //Height of items in list
    ddl.setBarHeight(30); //Height of the list button
    ddl.setWidth(120); //width of the list
    ddl.captionLabel().set("Acce range"); //text shown in the list button
    ddl.captionLabel().style().marginTop = 5; //distance from the text and the top
    ddl.captionLabel().style().marginLeft = 10; //distance from the text and the left corner
    ddl.valueLabel().style().marginTop = 3; //I don't know what this does

    ddl.setColorBackground(color(50,53,54)); //background color of the list
    ddl.setColorForeground(color(90)); //color when an element of the list is highlighted
    ddl.setColorActive(color(250)); //color when a element is selected (for a brief instant)

    ddl.addItem("2G",0);
    ddl.addItem("4G",1);
    ddl.addItem("8G",2);
    ddl.addItem("16G",3);
}

void
gyro_range_ddl(DropdownList ddl)
{
    ddl.setItemHeight(30); //Height of items in list
    ddl.setBarHeight(30); //Height of the list button
    ddl.setWidth(120); //width of the list
    ddl.captionLabel().set("Gyro range"); //text shown in the list button
    ddl.captionLabel().style().marginTop = 5; //distance from the text and the top
    ddl.captionLabel().style().marginLeft = 10; //distance from the text and the left corner
    ddl.valueLabel().style().marginTop = 3; //I don't know what this does

    ddl.setColorBackground(color(50,53,54)); //background color of the list
    ddl.setColorForeground(color(90)); //color when an element of the list is highlighted
    ddl.setColorActive(color(250)); //color when a element is selected (for a brief instant)

    ddl.addItem("250d/s",0);
    ddl.addItem("500d/s",1);
    ddl.addItem("1000d/s",2);
    ddl.addItem("2000d/s",3);
}

void
sampling_ddl(DropdownList ddl)
{
    ddl.setItemHeight(30); //Height of items in list
    ddl.setBarHeight(30); //Height of the list button
    ddl.setWidth(120); //width of the list
    ddl.captionLabel().set("Sampling rate"); //text shown in the list button
    ddl.captionLabel().style().marginTop = 5; //distance from the text and the top
    ddl.captionLabel().style().marginLeft = 10; //distance from the text and the left corner
    ddl.valueLabel().style().marginTop = 3; //I don't know what this does

    ddl.setColorBackground(color(50,53,54)); //background color of the list
    ddl.setColorForeground(color(90)); //color when an element of the list is highlighted
    ddl.setColorActive(color(250)); //color when a element is selected (for a brief instant)

    ddl.addItem("10Hz",10);
    ddl.addItem("50Hz",50);
    ddl.addItem("60Hz",60);
    /*ddl.addItem("100Hz",100);*/
    /*ddl.addItem("500Hz",500);*/
}

boolean ddlaux_eventHandler(String group_name, int value)
{
    if(group_name == "port_list")
    {
        try
        {
            myPort = new Serial(this, comList[value], 38400);
            port_selected = true;
        }
        catch(Exception ex)
        {
            port_selected = false;
            println("failed");
            WarningMessageBox.show("failed to connect to port");
            port_list.captionLabel().set("Serial port");
        }
        return true;
    } else {
        if(port_selected == false && (group_name == "acce_list" || group_name == "gyro_list" || group_name == "sampling_list")){
            println("No port is connected");
            gyro_list.captionLabel().set("Gyro range");
            acce_list.captionLabel().set("Acce range");
            sampling_list.captionLabel().set("Sampling rate");
            return true;
        }
        else if(group_name == "acce_list")
        {
            myPort.write("1 " + value + ' ');
            return true;
        }
        else if(group_name == "gyro_list")
        {
            myPort.write("2 " + value + ' ');
            return true;
        }
        else if(group_name == "sampling_list")
        {
            //accelgyro.set_timeScale(value);
            myPort.write("3 " + value + ' ');
            return true;
        }
    }
    return false;
}
