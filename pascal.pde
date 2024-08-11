//Graphical representation of the Sierpiński triangle based on Pascal's triangle and modulo
//operations on the binomial coefficients

int rectWidth = 20, rectHeight = 20;
int MAX_DIVISOR = 10;                       //maximum modulo divisor that should be used
int MAX_N_ROWS = 675;                       //max number of rows which should be displayed

int[][][] binomials = new int[MAX_DIVISOR][0][];

PImage imgControls;                         //controls instruction image

boolean FIXED = false;                      //when image is fixed, no changes to height/divisor/zoom are allowed
boolean SHOW_NUMBERS = true;                //wether the binomial coefficients are drawn as text over the boxes
boolean SHOW_BORDERS = false;               //wether to show borders around the boxes

int colorMode = 1;                          //color scheme used to color the triangle
int COLOR_BW = 0;
int COLOR_RED = 1;
int COLOR_BLUE = 2;
int COLOR_GREEN = 3;


//Some arbitrarly set bounds for nice scaling
//lower number means zoomed out, bigger number zoomed in

int ZOOM_UPPER_BOUND = 80;                  //biggest rectWidth for which zooming in should be available
int ZOOM_LOWER_BOUND = 2;                   //smallest rectWidth for which zooming out should be available (do not go below 2 without changing zoomfactors)

int MAX_BOUND_SHOW_TEXT = 40;               //lowest rectWidt for which text should be displayed, disregarding SHOW_NUMBERS

float ZOOM_FACTOR_BIGGER = 2;               //factor with which rectWidth is multiplied on zooming in
float ZOOM_FACTOR_SMALLER = 0.5;            //factor with which rectWidth is multiplied on zooming out


void setup()
{
    size(1280, 720);
    background(255);
    textAlign(CENTER, CENTER);
    
    imgControls = loadImage("controls.png");
}

void draw() {  
    if (!FIXED) {
        background(255);
        
        image(imgControls, 10, 10, 400, 200);
        drawBoxesWithMouseMapping();   
    }
}

void drawBoxesWithMouseMapping() {
    //Map mouse movement to the row count of the triangle and the divisor
    int rows = int(map(mouseY, 0, height, 0, height / rectHeight));
    int divisor = int(map(mouseX, 0, width, 1, MAX_DIVISOR));
    
    if (rows >= MAX_N_ROWS) {
        textSize(20);
        fill(0);
        textAlign(LEFT);
        text("Maximum possible number of rows computed", 10, height - 25);
    }
    
    rows = min(rows, MAX_N_ROWS);
    
    drawBoxes(rows, divisor);
}

void drawBoxes(int nRows, int mod)
    {
    //As computing the binomial coefficients is slow, only compute it once a
    //bigger row count than the current length is requested
    if (nRows > binomials[mod].length) {
        binomials[mod] = new int[nRows][];    
        generateBinomials(nRows, mod, binomials);
    }
    
    //Drawing the boxes
    for (int i = 0; i < nRows; ++i) {
        float startX = width / 2 - (i / 2.0f * rectWidth);
        for (int j = 0; j < i; ++j) {
            float x = startX + j * rectWidth;
            float y = rectHeight * i;
            
            int colorNum = binomials[mod][i - 1][j];
            
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
            
            if (SHOW_NUMBERS && nRows < MAX_BOUND_SHOW_TEXT) {
                fill(0);
                textAlign(CENTER, CENTER);
                textSize(rectHeight / 2);
                text(String.valueOf(binomials[mod][i - 1][j]), x,y, rectWidth, rectHeight);
            }
        }
    }
    fill(0);
    textAlign(RIGHT);
    textSize(25);
    text("Divisor: " + mod, width - 50, 50);
    
}

void generateBinomials(int nRows, int mod, int[][][] binomTbl) {
    //Generates Pascal's triangle which looks like this:
    //1
    //1 1
    //1 2 1
    //1 3 3 1
    //1 4 6 4 1
    //...
    
    //Very slow, should be improved further, with bigger data types to compute more rows
    
    //binomTbl is an array of string arrays in which the binomial coefficients are stored                     
    binomTbl[mod][0] = new int[]{1};
    binomTbl[mod][1] = new int[]{1,1};
    
    for (int i = 2; i < nRows; ++i) {
        int prevLen = binomTbl[mod][i - 1].length;
        int[]row = new int[prevLen + 1];
        
        //Add a "1" to start and end
        row[0] = 1;
        row[prevLen] = 1;
        
        //Fill up the values in between with the sum of the two values (left, right) of the previous row
        for (int j = 0; j < prevLen - 1; ++j) {
            int left = binomTbl[mod][i - 1][j];
            int right = binomTbl[mod][i - 1][j + 1];
            row[1 + j] = (left + right)%mod;
        }
        
        binomTbl[mod][i] = row;
    }
}


//Controls
void mouseWheel(MouseEvent event) {
    //Simply mapping the scroll wheel to +/- zoom
    float e = event.getCount();
    float scaling = map(e, 1, -1, ZOOM_FACTOR_SMALLER, ZOOM_FACTOR_BIGGER);
    zoom(scaling); 
}

void keyPressed() {
    print("Registered key storke: " + key);
    switch((key + "").toLowerCase()) {
        case "+":
            zoom(ZOOM_FACTOR_BIGGER);
            break;
        case "-":
            zoom(ZOOM_FACTOR_SMALLER);
            break;
        case "f":
            print("\nToggled fixation mode");
            FIXED = !FIXED;
            if (FIXED) {
                textSize(20);
                fill(0);
                textAlign(LEFT);
                text("Image frozen, to unlock press f", 10, height - 50);
            }
            
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
    if ((rectWidth <=  ZOOM_UPPER_BOUND && scaling > 1) || (rectWidth>= ZOOM_LOWER_BOUND && scaling <1)) {
        rectWidth *=  scaling;
        rectHeight *=  scaling;
    }
}
