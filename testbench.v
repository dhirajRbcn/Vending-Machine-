module q710_tb();

reg clk,rst,start;
reg money_5, money_10, money_20, money_50, money_100;
reg [3:0] quantity_cold_drink,quantity_dairy_milk,quantity_biscuits,quantity_red_bull,quantity_imported_chocolate;
reg add_more;
wire [31:0] change,refund;
wire [3:0] dispense_cold_drink, dispense_dairy_milk, dispense_biscuits, dispense_red_bull, dispense_imported_chocolate;
wire [31:0] notes_100, notes_50, notes_20, notes_10, notes_5;

q710 dut(clk,rst,start,money_5, money_10, money_20, money_50, money_100,quantity_cold_drink,quantity_dairy_milk,quantity_biscuits,quantity_red_bull,quantity_imported_chocolate,add_more,dispense_cold_drink, dispense_dairy_milk, dispense_biscuits, dispense_red_bull, dispense_imported_chocolate,change,refund,notes_100, notes_50, notes_20, notes_10, notes_5);

initial begin
	$dumpfile("q710.vcd");
	$dumpvars();
end

always #2 clk=~clk;

initial begin
	$monitor(" > total_amount=%0d|total_cost=%0d|add_more=%0d|change=%0d|notes5=%0d|notes10=%0d|notes20=%0d|notes50=%0d|notes100=%0d|dispense_cold_drink=%d|dispense_dairy_milk=%d|dispense_biscuits=%d|dispense_red_bull=%d|dispense_imported_chocolate=%d",dut.total_amount,dut.total_cost,dut.add_more,dut.change,dut.notes_5,dut.notes_10,dut.notes_20,dut.notes_50,dut.notes_100, dispense_cold_drink, dispense_dairy_milk, dispense_biscuits, dispense_red_bull, dispense_imported_chocolate);

	clk=0;rst=1;money_100=4'd1;start=0;
	{quantity_dairy_milk,quantity_cold_drink,quantity_biscuits,quantity_red_bull,quantity_imported_chocolate}=0; {money_5, money_10,money_50,money_20}=0;add_more=0;
	#4 money_100=0;
	#4 start=1;
	#3 start=0;
	quantity_dairy_milk=4'd1;quantity_cold_drink=4'd0;add_more=0;
	//	#4 money_100=0;money_50=0;

	#7 money_100=0;money_50=0; quantity_cold_drink=0;quantity_dairy_milk=0;
	add_more=1; quantity_imported_chocolate=4'd1;quantity_cold_drink=4'd1;
	#6 add_more=0;quantity_imported_chocolate=4'd0;	quantity_cold_drink=4'd0;

	//2nd case
	#14 money_100=4'd1;
	#6 money_100=0;
	#3 start=1;
	#4 start=0;quantity_dairy_milk=4'd1;
	#8 money_100=0;quantity_dairy_milk=0;
	add_more=1; quantity_imported_chocolate=4'd1;quantity_cold_drink=4'd1;
	#6 add_more=0;quantity_imported_chocolate=4'd0;quantity_cold_drink=4'd0;

	//3rd case
	#21 money_50=4'd1;
	#6 money_50=0;
	#4 start=1;
	#3 start=0;quantity_imported_chocolate=4'd2;
	#4 add_more=0;quantity_imported_chocolate=0;
	//#6 add_more=0;

	//4 case
	#7 money_50=4'd1;
	#6 money_50=0;
	#4 start=1;
	#3 start=0;quantity_cold_drink=4'd2;quantity_biscuits=4'd2;
	#8 money_50=0;quantity_cold_drink=0;
	add_more=0;quantity_biscuits=4'd0;
	#6 add_more=0;quantity_biscuits=4'd0;

	//2nd case
	#9 money_100=4'd1;
	#10 money_100=0;
	#2 start=1;
	#2 start=0;quantity_dairy_milk=4'd1;
	#8 money_100=0;quantity_dairy_milk=0;
	#2 add_more=1; quantity_imported_chocolate=4'd1;quantity_cold_drink=4'd1;
	#6 add_more=0;quantity_imported_chocolate=4'd0;quantity_cold_drink=4'd0;
	#100 $finish;
end
endmodule
