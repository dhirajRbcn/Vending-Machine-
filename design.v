module machine(
	input clk, rst, start,
	input  money_5, money_10, money_20, money_50, money_100,
	input [3:0] quantity_cold_drink, quantity_dairy_milk, quantity_biscuits, quantity_red_bull, quantity_imported_chocolate,
	input add_more,
	output reg [3:0] dispense_cold_drink, dispense_dairy_milk, dispense_biscuits, dispense_red_bull, dispense_imported_chocolate,
	output reg signed [31:0]change, refund,
	output reg [31:0] notes_100, notes_50, notes_20, notes_10, notes_5);

localparam IDLE = 4'h0, START = 4'h1, SELECT = 4'h2, CHANGE = 4'h3, ASK_MORE = 4'h4, DISPENSE = 4'h5;
reg [3:0] present_state, next_state;
reg integer total_amount=0, total_cost=0, remaining_change=0, remaining_refund=0;
parameter COLD_DRINK = 10, DAIRY_MILK = 45, BISCUITS = 5, RED_BULL = 75, IMPORTED_CHOCOLATE = 135;
reg [3:0] purchased_cold_drink=0, purchased_dairy_milk=0, purchased_biscuits=0, purchased_red_bull=0, purchased_imported_chocolate=0;
reg [3:0] previous_cold_drink=0, previous_dairy_milk=0, previous_biscuits=0, previous_red_bull=0, previous_imported_chocolate=0;
reg [3:0] flag = 2'd0;
reg startflag=0;

initial begin 
	present_state = IDLE; 
	change = 0;
	notes_100 = 0; notes_50 = 0; notes_20 = 0; notes_10 = 0; notes_5 = 0;
	dispense_cold_drink = 0; dispense_dairy_milk = 0; dispense_biscuits = 0; dispense_red_bull = 0; dispense_imported_chocolate = 0;
end

always @(posedge clk or negedge rst) begin
	if (!rst)begin
		present_state <= IDLE;
	end
	else
		present_state <= next_state;
	calculate_money_in;
end

task calculate_money_in;
	total_amount = total_amount+(money_5 * 5) + (money_10 * 10) + (money_20 * 20) + (money_50 * 50) + (money_100 * 100);
endtask

task calculate_notes;
	input [9:0] amount;
	begin
		notes_100 = amount / 100;
		amount = amount % 100;
		notes_50 = amount / 50;
		amount = amount % 50;
		notes_20 = amount / 20;
		amount = amount % 20;
		notes_10 = amount / 10;
		amount = amount % 10;
		notes_5 = amount / 5;
	end
endtask

always @(*) begin
	case (present_state)
		IDLE: begin
			if(remaining_refund) begin total_amount = 0; total_cost = 0; remaining_change = 0; remaining_refund = 0; change = 0;notes_100 = 0;
			notes_50 = 0; notes_20 = 0; notes_10 = 0; notes_5 = 0;
		end
		{previous_cold_drink,previous_dairy_milk,previous_biscuits,previous_red_bull,previous_imported_chocolate}=0;
		{purchased_cold_drink,purchased_dairy_milk,purchased_biscuits,purchased_red_bull,purchased_imported_chocolate} = 0;
		{dispense_cold_drink,dispense_dairy_milk,dispense_biscuits,dispense_red_bull,dispense_imported_chocolate}= 0;
		next_state = (total_amount > 0 && {money_5
		,money_10,money_20,money_50,money_100}==0) ? START : IDLE;
	end

	START: begin
		if(start) 
			startflag=1;
		next_state = (startflag) ? SELECT : START;
	end

	SELECT: begin
		previous_cold_drink = purchased_cold_drink - previous_cold_drink;
		previous_dairy_milk = purchased_dairy_milk - previous_dairy_milk;
		previous_biscuits = purchased_biscuits - previous_biscuits;
		previous_red_bull = purchased_red_bull - previous_red_bull;
		previous_imported_chocolate = purchased_imported_chocolate - previous_imported_chocolate;

		purchased_cold_drink += quantity_cold_drink;
		purchased_dairy_milk += quantity_dairy_milk;
		purchased_biscuits += quantity_biscuits;
		purchased_red_bull += quantity_red_bull;
		purchased_imported_chocolate += quantity_imported_chocolate;

		total_cost += (COLD_DRINK * quantity_cold_drink) +
			(DAIRY_MILK * quantity_dairy_milk) +
			(BISCUITS * quantity_biscuits) +
			(RED_BULL * quantity_red_bull) +
			(IMPORTED_CHOCOLATE * quantity_imported_chocolate);
		next_state = (total_cost > 0) ? CHANGE : SELECT;
	end

	CHANGE: begin
		if (total_amount >= total_cost) begin
			remaining_change = total_amount - total_cost;
		end else begin
			if(remaining_change==0) begin
				purchased_cold_drink = 0;
				purchased_dairy_milk = 0;
				purchased_biscuits = 0;
				purchased_red_bull = 0;
				purchased_imported_chocolate = 0;
				remaining_refund = total_amount;
				calculate_notes(remaining_refund);
				change = total_amount;   

				next_state = IDLE;
			end 
		end

		if (remaining_change < total_cost && total_amount >= total_cost && flag == 4'd3) begin
			next_state = ASK_MORE;
			flag = 4'd0;
		end

		else if (remaining_change && total_amount < total_cost && flag == 2'd3) begin
			purchased_cold_drink -= previous_cold_drink;
			purchased_dairy_milk -= previous_dairy_milk;
			purchased_biscuits -= previous_biscuits;
			purchased_red_bull -= previous_red_bull;
			purchased_imported_chocolate -= previous_imported_chocolate;

			calculate_notes(remaining_change);
			change = remaining_change;
			next_state = DISPENSE;
			flag = 0;
		end 
		else if (total_amount >= total_cost && flag == 0) begin
			next_state = ASK_MORE;
		end 
		else if (remaining_change > 0 && flag == 2'd1) begin
			calculate_notes(remaining_change);
			change = total_amount - total_cost;
			next_state = DISPENSE;
			flag = 2'd2;
		end
	end

	ASK_MORE: begin
		if (remaining_change > 0 && add_more) begin
			flag = 4'd3;
			next_state = SELECT;
		end else begin
			flag = 4'd1;
			next_state = CHANGE;
		end
	end

	DISPENSE: begin
		dispense_cold_drink = purchased_cold_drink;
		dispense_dairy_milk = purchased_dairy_milk;
		dispense_biscuits = purchased_biscuits;
		dispense_red_bull = purchased_red_bull;
		dispense_imported_chocolate = purchased_imported_chocolate;

		change = 0;startflag=0;
		notes_100 = 0; notes_50 = 0; notes_20 = 0; notes_10 = 0; notes_5 = 0;
		total_amount = 0; total_cost = 0; remaining_change = 0;flag=0;
		purchased_cold_drink = 0; purchased_dairy_milk = 0; purchased_biscuits = 0; purchased_red_bull = 0; purchased_imported_chocolate = 0;
		next_state = IDLE;
	end

	default: next_state = IDLE;

endcase
end
endmodule
