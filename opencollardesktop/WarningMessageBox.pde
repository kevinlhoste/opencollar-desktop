import controlP5.*;

static ControlGroup w_box;

public static class WarningMessageBox
{    
    static private Textlabel w_label;
    static private Button w_button;
    
    static void warningBox_init(ControlP5 cP5, int color1, int color2, int color3, PFont f)
    {
        w_box = cP5.addGroup("warningErrorBox",350,250,400);
        w_box.setBackgroundHeight(200);
        w_box.setBackgroundColor(color1);
        w_box.hideBar();
        w_box.hide();

        w_label = cP5.addTextlabel("warningLabel").setText("No text defined").setPosition(100,20).setFont(f);
        w_label.moveTo(w_box);

        w_button = cP5.addButton("warningButton");
        w_button.setCaptionLabel("OK");
        w_button.setSize(100,30);
        w_button.setPosition(150,150);
        w_button.setColorActive(color2);
        w_button.setColorBackground(color3);
        w_button.setColorForeground(color2);
        w_button.getCaptionLabel().align(cP5.CENTER, cP5.CENTER);
        w_button.moveTo(w_box);
    }

    static public void show(String msg)
    {
        w_label.setText(msg);
        w_box.show();
    }
}

void warningButton()
{
    w_box.hide();
}
