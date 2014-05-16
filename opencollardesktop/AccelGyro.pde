static int SAMPLES = 30000;

String
    file_name;

int
    C_RED = color(200,89,91),
    C_BLUE = color(81,162,198),
    C_YELLOW = color(207,209,121),
    C_VIOLET = color(115,97,167),
    C_CIAN = color(91,196,194),
    C_GREEN = color(100,188,111),
    NButton1 = color(92,196,194),
    NButton2 = color(0,0,0,180),
    NButton3 = color(0,0,0,1);

boolean LiveModeState,
        WriteModeState,
        write_to_file;

PrintWriter fileOut;

public class AccelGyro
{
    boolean
        set_ax,
        set_ay,
        set_az,
        set_gx,
        set_gy,
        set_gz;
        
    private float[]
        ax,
        ay,
        az,
        gx,
        gy,
        gz;
    private int 
        start,
        total,
        screen_size;
    private float
        graphMultAX,
        graphMultAY,
        graphMultGX,
        graphMultGY;
    private int
        acc_VerticalOrigin,
        gyro_VerticalOrigin;
    
    private Button bLive, bWrite, bRead, bByteLive, bFile;
    
    public 
    AccelGyro(ControlP5 cP5){
        ax = new float[SAMPLES];
        ay = new float[SAMPLES];
        az = new float[SAMPLES];
        gx = new float[SAMPLES];
        gy = new float[SAMPLES];
        gz = new float[SAMPLES];
        start = 0;
        total = 0;
        screen_size = 250;
        graphMultAX = 4;
        //graphMultAY = 50;
        graphMultAY = 0.004;
        graphMultGX = 4;
        //graphMultGY = 400/250;
        graphMultGY = 0.004;
        acc_VerticalOrigin = 194 + 33;
        gyro_VerticalOrigin = 533;
        set_ax = true;
        set_ay = true;
        set_az = true;
        set_gx = true;
        set_gy = true;
        set_gz = true;
    
        bLive = cP5.addButton("LiveMode").setPosition(480,0).setSize(80,29);
        bWrite = cP5.addButton("WriteMode").setPosition(480+80,0).setSize(80,29);
        bRead = cP5.addButton("ReadMode").setPosition(480+80+80,0).setSize(80,29);
        /*bByteLive = cP5.addButton("ByteMode").setPosition(480+80+80+80,0).setSize(80,29);*/
        bFile = cP5.addButton("FileOut").setPosition(480+80+80+80+80,0).setSize(80,29);
        LiveModeState = false;
        WriteModeState = false;
        write_to_file = false;
    
        cP5.addToggle("toggleV")
            .setPosition(5,33)
            .setSize(26,26)
            .setState(true)
            .setColorActive(NButton3)
            .setColorBackground(NButton2)
            .setColorForeground(NButton2)
            .captionLabel().setVisible(false);
       
        cP5.addToggle("toggleR")
            .setPosition(5+33,33)
            .setSize(26,26)
            .setState(true)
            .setColorActive(NButton3)
            .setColorBackground(NButton2)
            .setColorForeground(NButton2)
            .captionLabel().setVisible(false);
            
        cP5.addToggle("toggleB")
            .setPosition(5+33+33,33)
            .setSize(26,26)
            .setState(true)
            .setColorActive(NButton3)
            .setColorBackground(NButton2)
            .setColorForeground(NButton2)
            .captionLabel().setVisible(false);
        
        cP5.addToggle("toggleY")
            .setPosition(5+33+33+33,33)
            .setSize(26,26)
            .setState(true)
            .setColorActive(NButton3)
            .setColorBackground(NButton2)
            .setColorForeground(NButton2)
            .captionLabel().setVisible(false);
        
        cP5.addToggle("toggleVI")
            .setPosition(5+33+33+33+33,33)
            .setSize(26,26)
            .setState(true)
            .setColorActive(NButton3)
            .setColorBackground(NButton2)
            .setColorForeground(NButton2)
            .captionLabel().setVisible(false);
            
        cP5.addToggle("toggleC")
            .setPosition(5+33+33+33+33+33,33)
            .setSize(26,26)
            .setState(true)
            .setColorActive(NButton3)
            .setColorBackground(NButton2)
            .setColorForeground(NButton2)
            .captionLabel().setVisible(false);
        
        
        Textlabel f_label;
        Button f_button;
  
        f_box = controlP5.addGroup("FileNameBox",350,250,400);
        f_box.setBackgroundHeight(200);
        f_box.setBackgroundColor(color(130));
        f_box.hideBar();
        f_box.hide();
        
        filename = controlP5.addTextfield("input").setPosition(10,40)
         .setPosition(100,70)
         .setSize(200,25)
         .setColorActive(255)
         .setColorBackground(255)
         .setColorCursor(255)
         .setFont(createFont("impact",18))
         .setFocus(true)
         .setColor(255)
         .setCaptionLabel(" ");
        filename.moveTo(f_box);   
        filename.hide();

        f_label = controlP5.addTextlabel("fileLabel").setText("Type the filename without extensions").setPosition(80,20).setFont(createFont("impact",12));
        f_label.moveTo(f_box);
        f_button = controlP5.addButton("fileButton");
        f_button.setCaptionLabel("OK");
        f_button.setSize(100,30);
        f_button.setPosition(150,150);
        f_button.setColorActive(color(0,0,0,180));
        f_button.setColorBackground(color(0,70));
        f_button.setColorForeground(color(0,0,0,180));
        f_button.getCaptionLabel().align(controlP5.CENTER, controlP5.CENTER);
        f_button.moveTo(f_box);
    }
    public void
    set_ax(){ set_ax = true; }
    public void
    unset_ax(){ set_ax = false; }
    public void
    set_ay(){ set_ay = true; }
    public void
    unset_ay(){ set_ay = false; }
    public void
    set_az(){ set_az = true; }
    public void
    unset_az(){ set_az = false; }
    public void
    set_gx(){ set_gx = true; }
    public void
    unset_gx(){ set_gx = false; }
    public void
    set_gy(){ set_gy = true; }
    public void
    unset_gy(){ set_gy = false; }
    public void
    set_gz(){ set_gz = true; }
    public void
    unset_gz(){ set_gz = false; }
    
    
    public void
    zoominAX(){ graphMultAX = graphMultAX*2; }   
    public void
    zoomoutAX(){ graphMultAX = graphMultAX/2; }
    public void
    zoominAY(){ graphMultAY = graphMultAY + 10;}
    public void
    zoomoutAY(){ graphMultAY = graphMultAY - 10;}
    public void
    zoominGX(){ graphMultGX = graphMultGX*2; }   
    public void
    zoomoutGX(){ graphMultGX = graphMultGX/2; }
    public void
    zoominGY(){ graphMultGY = graphMultGY + 10;}
    public void
    zoomoutGY(){ graphMultGY = graphMultGY - 10;}
    
    public void 
    add_values(float aX, 
               float aY,
               float aZ,
               float gX,
               float gY,
               float gZ)
    {
        int pos = (start + total) % screen_size;
        ax[pos] = aX;
        ay[pos] = aY;
        az[pos] = aZ;
        gx[pos] = gX;
        gy[pos] = gY;
        gz[pos] = gZ;
        if(total < screen_size) total++;
        else start = (start+1)%screen_size;
    }
    
    public void
    set_timeScale(int value)
    {
        switch(value)
        {
            case 10:
                graphMultAX = 4;
                graphMultGX = 4;
                break;
            case 50:
                graphMultAX = 4/5;
                graphMultGX = 4/5;
                break;
            case 100:
                graphMultAX = 4/10;
                graphMultGX = 4/10;
                break;
            case 500:
                graphMultAX = 4/50;
                graphMultGX = 4/50;
                break;
        }
    }
    
    public void 
    clear_values()
    {
        total = 0;
        start = 0;
    }
 
    private void 
    draw_axes(){
        stroke (0);
        line(8,acc_VerticalOrigin,1024-12,acc_VerticalOrigin);
        line(8,gyro_VerticalOrigin,1024-12,gyro_VerticalOrigin);
    }
    
    private void
    draw_line(float[] values, int myColor, float multX, float multY, int vOrigin)
    {
        float x0, y0, x1, y1;
        for(int i = 0; i < (total-1); i++)
        {
            x0 = i*multX + 10;
            y0 = vOrigin-(values[(start+i)%screen_size])*multY;
            x1 = (i+1)*multX + 10;
            y1 = vOrigin-(values[(start+i+1)%screen_size])*multY;
            
            strokeWeight(1);
            stroke(myColor);
            line(x0,y0,x1,y1);
        }
    }
    
    private void 
    draw_graphBoxes() {
        // ecran blanc 
        fill(255);
        rect(8 ,8+66 , 1024-8-11 ,300 );
        // ecran blanc 2  
        noStroke();
        fill(255);
        rect(8 ,8+66+8+300 , 1024-8-11 ,300 );
    }
    
    private void draw_graphLegends()
    {
        // This draws the graph key info
        strokeWeight(1.5);
  
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

    void draw_checkBoxes() {
        // bande noire 
        noStroke();
        fill(50,53,54);
        rect(0 ,29 , 3+33+33+33+33+33+33, 36);
        // fond bouton vert
        noStroke();
        fill(C_GREEN);
        rect(3 ,31 , 30 ,30 ); 
        // fond bouton rouge
        noStroke();
        fill(C_RED);
        rect(3+33 ,31 , 30 ,30 ); 
        // fond bouton bleu
        noStroke();
        fill(C_BLUE);
        rect(3+33+33 ,31 , 30 ,30 );
        // fond bouton jaune
        noStroke();
        fill(C_YELLOW);
        rect(3+33+33+33 ,31 , 30 ,30 );
        // fond bouton violet
        noStroke();
        fill(C_VIOLET);
        rect(3+33+33+33+33 ,31 , 30 ,30 );
        // fond bouton cyan
        noStroke();
        fill(C_CIAN);
        rect(3+33+33+33+33+33 ,31 , 30 ,30 );
        //push inside of the stack
    }

    
    public void
    draw()
    {
        draw_checkBoxes();
        draw_graphBoxes();
        draw_axes();
        //draw_graphLegends();
        
        if(set_ax == true) draw_line(ax,C_GREEN,graphMultAX,graphMultAY,acc_VerticalOrigin);
        if(set_ay == true) draw_line(ay,C_RED,graphMultAX,graphMultAY,acc_VerticalOrigin);
        if(set_az == true) draw_line(az,C_BLUE,graphMultAX,graphMultAY,acc_VerticalOrigin);
        if(set_gx == true) draw_line(gx,C_YELLOW,graphMultGX,graphMultGY,gyro_VerticalOrigin);
        if(set_gy == true) draw_line(gy,C_VIOLET,graphMultGX,graphMultGY,gyro_VerticalOrigin);
        if(set_gz == true) draw_line(gz,C_CIAN,graphMultGX,graphMultGY,gyro_VerticalOrigin);
        
    }
}

void toggleV(boolean flag) 
{
    if(flag){ accelgyro.set_ax(); println("set"); }
    else { accelgyro.unset_ax(); println("unset"); }
}

void toggleR(boolean flag) 
{
    if(flag){ accelgyro.set_ay(); println("set"); }
    else { accelgyro.unset_ay(); println("unset"); }
}

void toggleB(boolean flag) 
{
    if(flag){ accelgyro.set_az(); println("set"); }
    else { accelgyro.unset_az(); println("unset"); }
}

void toggleY(boolean flag) 
{
    if(flag){ accelgyro.set_gx(); println("set"); }
    else { accelgyro.unset_gx(); println("unset"); }
}

void toggleVI(boolean flag) 
{
    if(flag){ accelgyro.set_gy(); println("set"); }
    else { accelgyro.unset_gy(); println("unset"); }
}

void toggleC(boolean flag) 
{
    if(flag){ accelgyro.set_gz(); println("set"); }
    else { accelgyro.unset_gz(); println("unset"); }
}

void LiveMode(int value)
{
    if(port_selected == true){
        if(LiveModeState == true) { myPort.write('q'); LiveModeState = false; }
        else { myPort.write('L'); LiveModeState = true; accelgyro.clear_values();}
    }
}

void ByteMode(int value)
{
    if(port_selected == true){
        if(LiveModeState == true) { myPort.write('q'); LiveModeState = false; }
        else { myPort.write('L'); LiveModeState = true; accelgyro.clear_values();}
    }
}

void WriteMode(int value)
{
    if(port_selected == true){
        if(WriteModeState == true) { myPort.write('q'); WriteModeState = false; }
        else { myPort.write('w'); WriteModeState = true; accelgyro.clear_values();}
    }
}

void ReadMode(int value)
{
    myPort.write('R');
}

static ControlGroup f_box;
static Textfield filename;

void FileOut()
{
  file_name = "";

  filename.show();
  f_box.show();
}

void fileButton()
{
  println(filename.getText());
  if(write_to_file)
  {
    fileOut.close();
  }
  try{
    fileOut = new PrintWriter(filename.getText()+".csv", "UTF-8");
  } catch(IOException e){
    write_to_file = false;
    filename.hide();
    f_box.hide();
    WarningMessageBox.show("failed to open file");
    return;
  }
  filename.hide();
  f_box.hide();
  write_to_file = true;
  myPort.write('i');
  filename.hide();
  f_box.hide();
}
