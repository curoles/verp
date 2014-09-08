/**@file
 * @brief     D Flip Flop VERP HWLib
 * @author    Igor Lesik
 * @copyright Igor Lesik 2014
 *
 * License    Distributed under the Boost Software License, Version 1.0.
 *            (See  http://www.boost.org/LICENSE_1_0.txt)
 */

%# Dff parameters:
% Name         = 'Dff' unless defined? Name
% Posedge      = true  unless defined? Posedge
% Gated_clk    = false unless defined? Gated_clk
% Enabled_data = false unless defined? Enabled_data
% Has_reset    = false unless defined? Has_reset
% Async_reset  = false unless defined? Async_reset
%#
% edge = Posedge ? 'posedge' : 'negedge'

/** D flip-flop module <%=Name%>
 *  Clock edge : <%=edge%>
 *  Gated clock: <%=Gated_clk.to_s%>
 *  Data enable: <%=Async_reset.to_s%>
 *  Reset      : <%=if Has_reset then "async=#{Async_reset}" else "no" end%>
 */
module <%=Name%> 
#(parameter WIDTH = 1)
(
   input  [WIDTH-1:0] d
  ,input              clk
  ,output reg [WIDTH-1:0] q
<%if Gated_clk%>  ,input clk_enable<%;end-%>
<%if Enabled_data%>  ,input enable<%;end-%>
<%if Has_reset%>  ,input reset<%;end-%>
);

  wire clk_signal = clk<%if Gated_clk then%> && clk_enable<%;end%>;

  always @(<%=edge%> clk_signal<%if Async_reset%> or <%=edge%> reset<%;end%>)
  begin
<%if Has_reset%>    if (reset) q[WIDTH-1:0] <= 'h0; else<%;end-%>
    <%if Enabled_data%>if (enable) <%;end%>q[WIDTH-1:0] <= d[WIDTH-1:0];
  end

endmodule

