`timescale 1ns/1ns	//定义时间刻度

module tb_uart_bytes_rx();

localparam	integer	BYTES    = 5						;	//一次接收的字节个数
localparam	integer	BPS 	 = 230400					;	//波特率
localparam	integer	CLK_FRE  = 50_000_000				;	//系统频率50M
localparam	integer	CNT      = 1000_000_000 / BPS		;	//计算出传输每个bit所需要的时间，单位：ns


reg 							sys_clk			;		//系统时钟
reg 							sys_rst_n		;		//系统复位，低电平有效	
reg 							uart_rxd		;		//UART接收数据线

wire	[(BYTES * 8 - 1):0] 	uart_bytes_data	;		//接收到的多字节数据，在uart_bytes_vld为高电平时有效
wire							uart_bytes_vld	;		//当其为高电平时，代表此时接收到的多字节数据有效

initial begin	
	sys_clk <=1'b0;	
	sys_rst_n <=1'b0;
	uart_rxd <=1'b1;
	
	#20 //系统开始工作
	sys_rst_n <=1'b1;
	
	#3000
	repeat(10) begin						//重复生成8位随机数
		rx_byte({$random} % 256);		//
	end
	#60	$finish();
end

always #10 sys_clk=~sys_clk;	//设置主时钟，20ns,50M

//定义任务，每次发送的数据10 位(起始位1+数据位8+停止位1)
task rx_byte(
	input [7:0] data
);
	integer i; //定义一个常量
	//用 for 循环产生一帧数据，for 括号中最后执行的内容只能写 i=i+1
	for(i=0; i<10; i=i+1) begin
		case(i)
		0: uart_rxd <= 1'b0;		//起始位
		1: uart_rxd <= data[0];		//LSB
		2: uart_rxd <= data[1];
		3: uart_rxd <= data[2];
		4: uart_rxd <= data[3];
		5: uart_rxd <= data[4];
		6: uart_rxd <= data[5];
		7: uart_rxd <= data[6];
		8: uart_rxd <= data[7];		//MSB
		9: uart_rxd <= 1'b1;		//停止位
		endcase
		#(CNT+10); 					//每发送1 位数据延时（加10是为了减小误差）
	end		
endtask 							//任务结束

//例化多字节接收模块
uart_bytes_rx #(
	.BYTES				(BYTES				),
	.BPS				(BPS				),		
	.CLK_FRE			(CLK_FRE			)		
)			
uart_bytes_rx_inst(			
	.sys_clk			(sys_clk			),			
	.sys_rst_n			(sys_rst_n			),
		
	.uart_bytes_data	(uart_bytes_data	),			
	.uart_bytes_vld		(uart_bytes_vld		),
	
	.uart_rxd			(uart_rxd			)	
);

endmodule 