char[] serial_buffer;
int size, buf_i;

void
serial_handler_init()
{
    serial_buffer = new char[200];
}

void
write_accelgyro(int ax, int ay, int az, int gx, int gy, int gz)
{
  if(write_to_file)
  {
    fileOut.println(ax + ";" + ay + ";" + az + ";" + gx + ";" + gy + ";" + gz + ";");
    fileOut.flush();
  }
}

int 
get_int_from_buffer()
{
    int value = 0;
    int signal = 1;
    if(serial_buffer[buf_i] == '-') { signal = -1; }
    for(;(serial_buffer[buf_i] < '0' || serial_buffer[buf_i] > '9') 
         && buf_i < size; buf_i++)
    {
        if(serial_buffer[buf_i] == '\0'){
            println("bad live packet");
            return 0;
        }
    }
    for(;(serial_buffer[buf_i] >= '0' && 
          serial_buffer[buf_i] <= '9' &&
          buf_i < size); buf_i++)
    {
        value = (value * 10) + (serial_buffer[buf_i] - '0');
    }
    return value * signal;
}

void
live_packet_handler()
{
    int ax, ay, az, gx, gy, gz;
    buf_i = 0;
    
    ax = get_int_from_buffer();
    ay = get_int_from_buffer();
    az = get_int_from_buffer();
    gx = get_int_from_buffer();
    gy = get_int_from_buffer();
    gz = get_int_from_buffer();
    
    accelgyro.add_values(float(ax),float(ay),float(az),float(gx),float(gy),float(gz));
    write_accelgyro(ax,ay,az,gx,gy,gz);
}

int
get_int_from_byte_buffer(int i)
{
    int value = 0;

    value *= 256;
    if(serial_buffer[i+1] < 0) value += (256 - serial_buffer[i+1]);
    else value += serial_buffer[i+1];
    value *= 256;
    if(serial_buffer[i] < 0) value += (256 - serial_buffer[i]);
    else value += serial_buffer[i];
    if(value > (256*256/2)) value = 256*256 - value;
    
    return value;
}

void
byte_packet_handler()
{
    int ax, ay, az, gx, gy, gz;
    ax = get_int_from_byte_buffer(2);
    ay = get_int_from_byte_buffer(4);
    az = get_int_from_byte_buffer(6);
    gx = get_int_from_byte_buffer(8);
    gy = get_int_from_byte_buffer(10);
    gz = get_int_from_byte_buffer(12);
    
    accelgyro.add_values(float(ax),float(ay),float(az),float(gx),float(gy),float(gz));
    write_accelgyro(ax,ay,az,gx,gy,gz);
}

void
info_packet_handler()
{
  if(!write_to_file) return;
  int hz;
  
  fileOut.print("i;");
  
  println("device ID = "+serial_buffer[2]);
  
  switch(serial_buffer[4])
  {
    case '0':
      fileOut.print("2;");
      break;
    case '1':
      fileOut.print("4;");
      break;
    case '2':
      fileOut.print("8;");
      break;
    case '3':
      fileOut.print("16;");
      break;
  }
  
    switch(serial_buffer[6])
  {
    case '0':
      fileOut.print("250;");
      break;
    case '1':
      fileOut.print("500;");
      break;
    case '2':
      fileOut.print("1000;");
      break;
    case '3':
      fileOut.print("2000;");
      break;
  }
  
  fileOut.println(get_int_from_byte_buffer(8) + ";");
  fileOut.println("ax;ay;az;gx;gy;gz;");
  fileOut.flush();
}

void 
serialEvent(Serial p)
{
    char aux;
    aux = p.readChar();
    if(aux == '\n')
    {
        serial_buffer[size++] = '\0';
        switch(serial_buffer[0])
        {
            case 'A':
                println("ACK");
                break;
            case 'M':
                for(int i = 0; serial_buffer[i] != '\0'; i++)
                    serial_buffer[i] = serial_buffer[i+2];
                //println(serial_buffer);
                for(int i = 0; serial_buffer[i] != '\0'; i++) print(serial_buffer[i]);
                println("");
                break;
            case 'U':
                println("collar received an unknown frame");
            case 'l':
                live_packet_handler();
                break;
            case 'L':
                byte_packet_handler();
                break;
            case 'r':
                live_packet_handler();
                break;
            case 'R':
                byte_packet_handler();
                break;
            case 'i':
                info_packet_handler();
                break;
                
        }
        //println(serial_buffer[0]);
        size = 0;
    }
    else
    {
        serial_buffer[size++] = aux;
    }   
}
