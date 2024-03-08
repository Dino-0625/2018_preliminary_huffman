module huffman(clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);
input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;

parameter Wait = 0;
parameter GetData = 1;
parameter Bubble = 2;
parameter Calculate = 3;
parameter MakeCode = 4;
parameter MakeCode_a = 5;
parameter Reorder = 6;
parameter StoreBack = 7;
parameter Shift = 8;
parameter MSB = 128;
reg [3:0] nextState;
reg [3:0] state;
reg [7:0] gray_data_ [1:6];
reg [2:0] value_order [1:6];
reg [2:0] huffman_order [1:6];
reg [7:0] huffman_code [1:6];
reg [6:0] data_count;
reg [4:0] pointer;
reg [4:0] x,y,z,calculatePosition,o,o2;
reg [2:0] target_y0,target_y1,p,array0_count, array1_count;
reg [2:0] target0_array [1:6];
reg [2:0] target1_array [1:6];
//reg [7:0] count_temp, value_temp, temp; //計數數值暫存, A1...暫存
reg [7:0] Mi_ [1:6];
wire [2:0] order, order2;
wire [7:0] count_temp = (state == Bubble) ? gray_data_[x] : gray_data_[z];
wire [7:0] value_temp = (state == Bubble) ? value_order[x] : value_order[z];
wire [8:0] temp = gray_data_[calculatePosition] + gray_data_[calculatePosition + 1];
assign order2 = value_order[o2];
assign order = value_order[o];
reg gotoShift,storeCNT, finishBubble, finishMakeCode, finishReorder, finishMakeCode_a, finish, finishGetData, finishShift;
assign CNT1 = gray_data_[1];
assign CNT2 = gray_data_[2];
assign CNT3 = gray_data_[3];
assign CNT4 = gray_data_[4];
assign CNT5 = gray_data_[5];
assign CNT6 = gray_data_[6];

assign CNT_valid = finishGetData;

assign HC1 = huffman_code[1];
assign HC2 = huffman_code[2];
assign HC3 = huffman_code[3];
assign HC4 = huffman_code[4];
assign HC5 = huffman_code[5];
assign HC6 = huffman_code[6];

assign M1 = Mi_[1];
assign M2 = Mi_[2];
assign M3 = Mi_[3];
assign M4 = Mi_[4];
assign M5 = Mi_[5];
assign M6 = Mi_[6];

assign code_valid = finish;
always@(state, gray_valid, storeCNT, gotoShift, x, finishMakeCode, finishReorder, finishMakeCode_a, finishGetData, finishShift, finishBubble)begin
	case(state)
		Wait:
			if(gray_valid == 1)
				nextState = GetData;
			else
				nextState = Wait;
		GetData:
			if(finishGetData == 1)begin
				nextState = Bubble;
			end
			else
				nextState = GetData;
	    Bubble:begin
			if(finishBubble == 1)
				nextState = Calculate;
			else 
				nextState = Bubble;
		end
		Calculate:
			nextState = MakeCode;
		Reorder:
			if(gotoShift == 1)
				nextState = Shift;
			else if(finishReorder == 1)
				nextState = Calculate;
			else 
				nextState = Reorder;
		MakeCode:begin
			if(finishMakeCode == 1)
				nextState = MakeCode_a;
			else
				nextState = MakeCode;
		end
		MakeCode_a:begin
			if(finishMakeCode_a == 1)
				nextState = Reorder;
			else 
				nextState = MakeCode_a;
		end
		Shift:
			if(finishShift == 1)
				nextState = StoreBack;
			else
				nextState = Shift;
		default:
			nextState = 4'd0;
	endcase
end

integer i, j;
always@(posedge clk)begin
  if(reset)
	state = 4'd0;
  else
    state = nextState;
  finishReorder <= 1'b0;
  finishBubble <= 1'b0;
  finishMakeCode <= 1'b0;
  finishMakeCode_a <= 1'b0;
  finishGetData <= 1'b0;
  finishShift <= 1'b0;
  finish <= 1'b0;
  gotoShift <= 1'b0;
 
  if(reset)begin
        pointer <= 0;
	data_count <= 7'd0;
	x <= 5'b00001;
	
	z <= 5'b00001;
       y <= 5'b00001;
	calculatePosition <= 5'd5;
	for(i = 1;i < 7;i = i + 1)begin
		value_order[i] <= i;
		gray_data_[i] <= 7'd0;
		Mi_[i] <= 7'd0;
		huffman_code[i] <= 7'd0; 
		target0_array[i] <= 3'b0;
		target1_array[i] <= 3'b0;
	end
  end
  else begin
	  case(state)
		GetData:begin
			data_count <= data_count + 7'd1;
			gray_data_[gray_data] <= gray_data_[gray_data] + 7'd1;
			if(data_count == 100)
				finishGetData <= 1'b1;
			else
				finishGetData <= 1'b0;
		end
		Bubble:begin
			//bubble sort
			//x:1 y:2 to 6
			//x:2 y:3 to 6
			//goal: x largest y smallest
			if(gray_data_[x] < gray_data_[x + 1])begin
				//count_temp = gray_data_[x];
				gray_data_[x] <= gray_data_[x + 1];
				gray_data_[x + 1] <= count_temp;
				
				//value_temp = value_order[x];
				value_order[x] <= value_order[x + 1];
				value_order[x + 1] <= value_temp;
			end
			else begin
				gray_data_[x] <= gray_data_[x];
				value_order[x] <= value_order[x];
				
			end
			if((x + y)< 6)begin
				x <= x + 5'd1;
			end
			else begin
				x <= 5'd1;
				if(y == 5'd5)begin
					finishBubble <= 1'b1;
				end
				else begin
					y <= y + 1;
				end
			end
		end
		Calculate:begin
			//initial y = buttom value = 5; x =1
			//when combine: y must combine with y - 1
			//until y = 2 ansd the loop end
			//
			//group member would increase in each loop
			//initial data_count = group member count = 1
			
			//combine
			//temp = gray_data_[y] + gray_data_[y + 1];
			o = calculatePosition;
			o2 = calculatePosition + 1;
			gray_data_[calculatePosition + 1] <= value_order[o];
			gray_data_[calculatePosition] <= temp[7:0];
			
			//makecode
			
			target_y1 <= value_order[o2];
			target_y0 <= value_order[o];
			calculatePosition <= calculatePosition - 5'd1;
			z <= calculatePosition;
			
				
			
		end
		Reorder:begin
			if(gray_data_[z] > gray_data_[z - 1] && z >= 2)begin
				//count_temp = gray_data_[z];
				gray_data_[z] <= gray_data_[z - 1];
				gray_data_[z - 1] <= count_temp;
				
				//value_temp = value_order[z];
				value_order[z] <= value_order[z - 1];
				value_order[z - 1] <= value_temp;
				z <= z - 5'd1;
			end
			else begin
				finishReorder <= 1'b1;
				if(calculatePosition == 5'b00000)
					gotoShift <= 1'b1;
				else
					z <= 5'd1;
				//calculatePosition <= calculatePosition - 5'd1;
				
				
			end
			
			
		end
		MakeCode:begin 
			Mi_[target_y0] <= (Mi_[target_y0] << 1) + 7'd1;
			Mi_[target_y1] <= (Mi_[target_y1] << 1) + 7'd1;
			huffman_code[target_y1] <= (huffman_code[target_y1] >> 1) + MSB;
			huffman_code[target_y0] <= (huffman_code[target_y0] >> 1);
			target0_array[1] <= target_y0;
			target1_array[1] <= target_y1;
			array0_count <= 3'd2;
			array1_count <= 3'd2;
			p <= 3'd1;
			finishMakeCode <= 1'b1;
			pointer <= calculatePosition + 5'd3;
		end
		
		MakeCode_a:begin
			if((gray_data_[pointer] == target0_array[p]) && (p < array0_count))begin
				Mi_[value_order[pointer]] <= (Mi_[value_order[pointer]] << 1) + 8'd1;
				huffman_code[value_order[pointer]] <= (huffman_code[value_order[pointer]] >> 1);
				array0_count <= array0_count + 3'd1;
				target0_array[array0_count] <= value_order[pointer];
				pointer <= pointer + 5'd1;
				p <= 3'd1;
			end
			else if((gray_data_[pointer] == target1_array[p]) && (p < array1_count))begin
				Mi_[value_order[pointer]] <= (Mi_[value_order[pointer]] << 1) + 8'd1;
				huffman_code[value_order[pointer]] <= (huffman_code[value_order[pointer]] >> 1) + MSB;
				array1_count <= array1_count + 3'd1;
				target1_array[array1_count] <= value_order[pointer];
				pointer <= pointer + 5'd1;
				p <= 3'd1;
			end
			else
				p <= p + 3'd1;
			if(pointer == 5'd7 || ((p >= array0_count) && (p >= array1_count)))begin
				finishMakeCode_a <= 1'b1;
				
			end
			
		end
		Shift:begin
			
			case(Mi_[pointer])
				8'b01111111: huffman_code[pointer] <= (huffman_code[pointer] >> 1);
				8'b00111111: huffman_code[pointer] <= (huffman_code[pointer] >> 2);
				8'b00011111: huffman_code[pointer] <= (huffman_code[pointer] >> 3);
				8'b00001111: huffman_code[pointer] <= (huffman_code[pointer] >> 4);
				8'b00000111: huffman_code[pointer] <= (huffman_code[pointer] >> 5);
				8'b00000011: huffman_code[pointer] <= (huffman_code[pointer] >> 6);
				8'b00000001: huffman_code[pointer] <= (huffman_code[pointer] >> 7);
			endcase
			pointer <= pointer + 1;
			if(pointer == 6)
				finishShift <= 1;
		end
		StoreBack:
			finish <= 1;
		default:begin
			finishReorder <= 0;
			finishBubble <= 0;
			finishMakeCode <= 0;
			finishMakeCode_a <= 0;
			finishGetData <= 0;
			finishShift <= 0;
			finish <= 0;
			
		end
	  endcase
   end
end
endmodule
