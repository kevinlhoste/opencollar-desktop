char[] serial_buffer;
int size, buf_i;

void
serial_handler_init()
{
    serial_buffer = new char[200];
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
}

void 
serialEvent(Serial p)
{
    char aux;
    aux = p.readChar();
    if(aux == '\n')
    {
        serial_buffer[size++] = '\0';
        //println(serial_buffer);
        switch(serial_buffer[0])
        {
            case 'A':
                println("ACK");
                break;
            case 'M':
                for(int i = 0; serial_buffer[i] != '\0'; i++)
                    serial_buffer[i] = serial_buffer[i+2];
                println(serial_buffer);
                break;
            case 'U':
                println("collar received an unknown frame");
            case 'l':
                live_packet_handler();
                break;
            case 'r':
                live_packet_handler();
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
