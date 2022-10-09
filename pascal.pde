//Graphical representation of the Sierpinski-Triangle based on Pascal's Triangle

int rectWidth = 20, rectHeight = 20;
int maxDivisor = 10;                        //maximum modulo divisor which can be used

String[][] binomials = new String[0][];

PImage imgControls;                                //instruction image

boolean FIXED = false;                      //when image is fixed, no changes to height/divisor/zoom are allowed
boolean SHOW_NUMBERS = true;                //wether the binomial coefficients are drawn as text over the boxes
boolean SHOW_BORDERS = false;               //wether to show borders around the boxes

int colorMode = 1;                          //color scheme used to color the triangle
int COLOR_BW = 0;
int COLOR_RED = 1;
int COLOR_BLUE = 2;
int COLOR_GREEN = 3;




void setup()
{
    size(1280, 720);
    background(255);
    imgControls = loadImage("controls.png");
    //textAlign(CENTER, CENTER);
    textAlign(CENTER, CENTER);
}

void draw() {  
    if (!FIXED) {
        background(255);
        fill(0);
        drawBoxesWithMouseMapping();   
    }
    image(imgControls, 10, 10, 400, 200);
}

void drawBoxesWithMouseMapping() {
    //Map mouse y-movement to the row count of the triangle
    int n = int(map(mouseY, 0, height, 0, height / rectHeight));
    int divisor = int(map(mouseX, 0, width, 1, maxDivisor));
    
    drawBoxes(n, divisor);
}

void drawBoxes(int nRows, int mod)
    {
    if (nRows > binomials.length) {
        binomials = new String[nRows][];    
        generateBinomials(nRows, binomials);
    }
    
    for (int i = 0; i < nRows; ++i) {
        float startX = width / 2 - (i / 2.0f * rectWidth);
        for (int j = 0; j < i; ++j) {
            float x = startX + j * rectWidth;
            float y = rectHeight * i;
            
            int colorNum = Integer.parseInt(binomials[i - 1][j]) % mod;
            int filler = int(map(colorNum, 0, mod - 1, 0, 250));
            int fillerR = int(map(colorNum, 0, mod - 1, 128, 250));
            int fillerG = int(map(colorNum, 0, mod - 1, 128, 250));
            int fillerB = int(map(colorNum, 0, mod - 1, 128, 250));
            
            switch(colorMode) {
                case 0:
                    fill(filler);
                    break;
                case 1:
                    fill(255, fillerG, 0);
                    break;
                case 2:
                    fill(0, fillerB, 255);
                    break;
                case 3:
                    fill(fillerR, 255, 0);
                    break;
            }
            
            if (!SHOW_BORDERS)
                noStroke();
            else
                stroke(10);
            rect(x, y, rectWidth, rectHeight);
            
            if (SHOW_NUMBERS) {
                fill(0);
                textAlign(CENTER, CENTER);
                textSize(rectHeight / 2);
                text(binomials[i - 1][j], x,y, rectWidth, rectHeight);
            }
        }
    }
    //fill(255);
    //rect(width-200, 50, 200, 25);
    fill(0);
    textAlign(RIGHT);
    textSize(25);
    text("Divisor: " + mod, width - 50, 50);
    
}

void generateBinomials(int nRows, String[][] binomTbl) {
    //Generates Pascal's triangle which looks like this:
    //1
    //1 1
    //1 2 1
    //1 3 3 1
    //1 4 6 4 1
    //...
    
    //Very slow, should be improved further
    
    //binomTbl is an array of string arrays in which the binomial coefficients are stored                     
    binomTbl[0] = new String[]{"1"};
    binomTbl[1] = new String[]{"1","1"};
    
    for (int i = 2; i < nRows; ++i) {
        int prevLen = binomTbl[i - 1].length;
        String[]row = new String[prevLen + 1];
        
        //Add a "1" to start and end
        row[0] = "1";
        row[prevLen] = "1";
        
        //Fill up the values in between with the sum of the two values (left, right) of the previous row
        for (int j = 0; j < prevLen - 1; ++j) {
            int left = Integer.parseInt(binomTbl[i - 1][j] + "");
            int right = Integer.parseInt(binomTbl[i - 1][j + 1] + "");
            row[1 + j] = String.valueOf(left + right);
        }
        
        binomTbl[i] = row;
    }
}


// int colorNum = (i * (i + 1) / 2 + j) % mod; //<-- This formula looks really nice!

//Controls
void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    float scaling = map(e, 1, -1, 0.5, 2);
    zoom(scaling); 
}

void keyPressed() {
    print("Registered key storke: " + key);
    switch((key + "").toLowerCase()) {
        case "+":
            zoom(2);
            break;
        case "-":
            zoom(0.5);
            break;
        case "f":
            print("\nToggled fixation mode");
            FIXED = !FIXED;
            if (FIXED)
                textSize(20);
            fill(0);
            textAlign(LEFT);
            text("Image frozen, to unlock press f", 10, height - 25);
            
            break;
        case "n":
            print("\nToggled text display mode");
            SHOW_NUMBERS = !SHOW_NUMBERS;
            break;
        case "b":
            print("\nToggled border display mode");
            SHOW_BORDERS = !SHOW_BORDERS;
            break; 
        case "c":
            print("Changed color mode");
            colorMode++;
            colorMode %=  4;
            break;     
    }
}

void zoom(float scaling) {
    if ((rectWidth <=  80 && scaling > 1) || (rectWidth>= 20 && scaling <1)) {
        rectWidth *=  scaling;
        rectHeight *=  scaling;
    }
    print("\n" + rectWidth);
}