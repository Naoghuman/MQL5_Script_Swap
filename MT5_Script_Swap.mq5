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
 * This script export an overview about the performance from the strategy 'Session-BreakOut London'.
 * 
 * Analyse will be the performance from the first BreakOut (LONG/SHORT9 and if in the same day
 * available the second BreakOut.
 * 
 * ============================================================================================
 */
#property copyright "Naoghuman (Peter Rogge)"
#property link      "https://github.com/Naoghuman/MQL5_Strategy_Session_BreakOut_London/"
#property version   "1.000"

input group "== 'Session-Breakout London' ======================="
input bool Trade_LONG  = true; // Trade LONG positions
input bool Trade_SHORT = true; // Trade SHORT positions

input group "== Time-Management ==============================="
input ENUM_TIMEFRAMES DelayAfterTrade   = PERIOD_M1; // Delay after a Trade
input int             BreakOutHour      = 9;         // BreakOut Hour (Local Time) from Session London
input int             BreakOutMinute    = 0;         // BreakOut Minute (Local Time) from Session London
input int             BreakOutCandlesNr = 1;         // Candles (before the BreakOut) defines the BreakOut-Range

// Enums
enum ENUM_BREAKOUT
{
   BREAKOUT_NONE  = 0, // No Breakout
   BREAKOUT_LONG  = 1, // LONG Breakout
   BREAKOUT_SHORT = 2  // SHORT Breakout
};

// Includes

// Defines

// Enums

// Input variables

// Global variables
bool   _InitializeBreakOutRange;
double _BreakOutPrice_High;
double _BreakOutPrice_Low;
double _BreakOut_1R;
double _BreakOut_Actual_Performace;
string _Comment;

ENUM_BREAKOUT _BreakOutType;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   _InitializeBreakOutRange = false;
   
   _BreakOutPrice_High = -7654321;
   _BreakOutPrice_Low  =  7654321;
   
   _BreakOut_1R                = 0;
   _BreakOut_Actual_Performace = 0;
   
   _BreakOutType = BREAKOUT_NONE;
   
   _Comment = "";
   Comment(_Comment);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment(""); 
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // ## Scan every market ####################################################################
   // Check time
   MqlDateTime _MqlDateTime;
   TimeToStruct(iTime(Symbol(), PERIOD_M15, 0), _MqlDateTime);
      
   // Check if we have a TradeDay (Monday - Friday).
   int _DayOfWeek;
   if (!IsTradeDay(_MqlDateTime, _DayOfWeek)) { return; }
   
   CheckIsSessionEndTime(_MqlDateTime);
   
   // Init BreakOut-Range (08:45 - 09:00)
   InitializeBreakOutRange(_MqlDateTime);
   
   // Trade only in the Session time (09:00 - 22:00)
   if (!IsSessionTime(_MqlDateTime)) { return; }
   
   // Comment: Weekday, Date Time
   AddCommentWeekdayDateTime(_DayOfWeek);
   /*
    * Weekday, Date Time
    * Market BreakOut W/L      MPR
    * AUDCAD =====    -1.00R   0.00R
    *        LONG      0.00R
    *        SHORT
    */
   CheckBreakOut();
   if (_BreakOutType != BREAKOUT_NONE) { return; }
   
   // Now we have a BreakOut previously check the actual performance
   CheckActualPerformance();
   
   _Comment += Symbol() + ": " + EnumToString(_BreakOutType) + "; " + DoubleToString(_BreakOut_Actual_Performace, 2);
   
   Comment(_Comment); 
}
//+------------------------------------------------------------------+

void AddCommentWeekdayDateTime(int _DayOfWeek)
{
   string _W  = GetWeekday(_DayOfWeek);
   string _D  = TimeToString(TimeLocal(), TIME_DATE   );
   string _TL = TimeToString(TimeLocal(), TIME_MINUTES);
   
   _Comment += _W + ", " + _D + " " + _TL + "/n";
}

void CheckActualPerformance()
{
   double _Close = iClose(Symbol(), PERIOD_M15, 0);
   if (_BreakOutType == BREAKOUT_LONG)
   {
      double _ActualPerformanceIn_R = (_Close - _BreakOutPrice_High) / _BreakOut_1R;
      _BreakOut_Actual_Performace   = NormalizeDouble(_ActualPerformanceIn_R, 2);
   }
   
   if (_BreakOutType == BREAKOUT_SHORT)
   {
      double _ActualPerformanceIn_R = (_BreakOutPrice_Low - _Close) / _BreakOut_1R;
      _BreakOut_Actual_Performace   = NormalizeDouble(_ActualPerformanceIn_R, 2);
   }
}

void CheckBreakOut()
{
   if (_BreakOutType != BREAKOUT_NONE) { return; }
   
   double _Close = iClose(Symbol(), PERIOD_M15, 0);
   if (_Close > _BreakOutPrice_High) { _BreakOutType = BREAKOUT_LONG;  }
   if (_Close < _BreakOutPrice_Low ) { _BreakOutType = BREAKOUT_SHORT; }
}

void CheckIsSessionEndTime(MqlDateTime &_MqlDateTime)
{
   int _Hour = _MqlDateTime.hour;
   int _Min  = _MqlDateTime.min;
   
   if (_Hour == (22 + 1) && _Min == 0)
   {
      _InitializeBreakOutRange = false;
      
      _BreakOutPrice_High = -7654321;
      _BreakOutPrice_Low  =  7654321;
      
      _BreakOut_1R                = 0;
      _BreakOut_Actual_Performace = 0;
   
      _BreakOutType = BREAKOUT_NONE;
   
      int _DayOfWeek = _MqlDateTime.day_of_week;
      AddCommentWeekdayDateTime(_DayOfWeek);
   }
}

string GetWeekday(int _Weekday)
{
   string _D = "ALL";
   switch(_Weekday)
   {
      case 0: { _D = "ALL";       break; }
      case 1: { _D = "MONDAY";    break; }
      case 2: { _D = "TUESDAY";   break; }
      case 3: { _D = "WEDNESDAY"; break; }
      case 4: { _D = "THURSDAY";  break; }
      case 5: { _D = "FRIDAY";    break; }
   }
   
   return _D;
}

void InitializeBreakOutRange(MqlDateTime &_MqlDateTime)
{
   if (_InitializeBreakOutRange) { return; }
   
   int _Hour = _MqlDateTime.hour;
   int _Min  = _MqlDateTime.min;
   if (_Hour == (8 + 1) && _Min == 0)
   {
      _BreakOutPrice_High = iHigh(Symbol(), PERIOD_M15, 1);
      _BreakOutPrice_Low  = iLow( Symbol(), PERIOD_M15, 1);
      _BreakOut_1R        = _BreakOutPrice_High - _BreakOutPrice_Low;
      
      _InitializeBreakOutRange = true;
   }
}

bool IsTradeDay(MqlDateTime &_MqlDateTime, int &_DayOfWeek)
{
   _DayOfWeek = _MqlDateTime.day_of_week;
   if (_DayOfWeek >= 1 && _DayOfWeek <= 5)
   {
      return true;
   }
   
   return false;
}

bool IsSessionTime(MqlDateTime &_MqlDateTime)
{
   int _Hour = _MqlDateTime.hour;
   int _Min  = _MqlDateTime.min;
   
   if (_Hour >= (BreakOutHour + 1) && _Hour < 23)
   {
      return true;
   }
   
   return false;
}
