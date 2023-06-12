/*
 * Copyright (C) 2023 Naoghuman
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/* ============================================================================================
 * DESCRIPTION
 * This script export an overview about the Swap (overnight fees) in the defined Forex-Markets.
 * 
 * Every value greater then 'InputThreshold' generates a 'Buy' or 'Sell' signal.
 * 
 * ============================================================================================
 * REPORT-STRUCTURE
 * 
 * SWAP (Date Time; Threshold = )
 * Market Swap (Long) Swap (Short) Signal
 * 
 * ============================================================================================
 */
#property copyright "Naoghuman (Peter Rogge)"
#property link      "https://github.com/Naoghuman/MQL5_Script_Swap"
#property version   "1.002"

// Input
// display window of the input parameters during the script's launch
#property script_show_inputs

input group "== 'Swap-Dividend' ================================="
input string InputMarket    = ""; // List of markets (separated with ;) which will be analysed
input string InputBroker    = ""; // The Broker which markets should be analysed
input double InputThreshold = 1;  // Values greater then 'n' generates a signal

// Enums

// Includes

// Defines

// Enums

// Input variables

// Global variables

void OnStart()
{
   // ## Open file ############################################################################
   Comment("");
   
   string _SpreadSheet       = "Swap_" + TimeToString(TimeLocal(), TIME_DATE) + "_" + InputBroker + ".csv";
   int    _SpreadSheetHandle = FileOpen(_SpreadSheet, FILE_READ | FILE_WRITE | FILE_CSV | FILE_UNICODE | FILE_COMMON);

   FileSeek(_SpreadSheetHandle, 0, SEEK_END);
   
   // ## Write header #########################################################################
   string _Header =   "SWAP ("
                    + TimeToString(TimeLocal(), TIME_DATE)
                    + " "
                    + TimeToString(TimeLocal(), TIME_MINUTES)
                    + "; Threshold = "
                    + DoubleToString(InputThreshold, 2)
                    + ")";
   FileWrite(_SpreadSheetHandle, _Header);
   FileWrite(_SpreadSheetHandle, "Market", "Swap (Long)", "Swap (Short)", "Signal");
   
   // ## Scan every market ####################################################################
   // Scan every market
   string _Markets[];
   StringSplit(InputMarket, ';', _Markets);
   
   int _SizeMarkets = ArraySize(_Markets);
   for (int _Index = 0; _Index < _SizeMarkets; _Index++)
   {
      string _Market    = _Markets[_Index];
      double _SwapLong  = SymbolInfoDouble(_Market, SYMBOL_SWAP_LONG );
      double _SwapShort = SymbolInfoDouble(_Market, SYMBOL_SWAP_SHORT);
      
      string _Signal = "N/A";
      if (_SwapLong  >= InputThreshold) { _Signal = "BUY";  }
      if (_SwapShort >= InputThreshold) { _Signal = "SELL"; }
      
      FileWrite(_SpreadSheetHandle, _Market, _SwapLong, _SwapShort, _Signal);
   }
   FileWrite(_SpreadSheetHandle, "");
   
   // ## Close file ###########################################################################
   FileClose(_SpreadSheetHandle);
   
   Comment("DONE " + _SpreadSheet); 
}
