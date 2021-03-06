/*==================================================================================
   

====================================================================================*/

// PARÁMETROS EXTERNOS

         bool     operar         =  true;
         bool     senal          =  false;
   
   double   i_hebelung     =  0.1;
   int      iter           =  1;


extern   int      i_atr          =  10;
extern   double   i_multi        =  1;
extern int i_takeprofit = 1000;
extern int i_stoploss = 200;


//VARIABLES GLOBALES

int      apaga_compra,
         apaga_venta,
         flag_close,
         _MagicNumber   =  7777777,
         stopbuy1, 
         stopbuy2, 
         stopsell1, 
         stopsell2;
               
double   open_price_buy,
         open_price_sell,
         account_balance_0,
         account_balance_1,
         account_equity,
         account_difference,
         account_profit,
         TrendUp[], 
         TrendDown[];
 
//+------------------------------------------------------------------+
//|                        INIT                                      |
//+------------------------------------------------------------------+
int init()
  {

   apaga_compra      =  0;
   apaga_venta       =  0;
   open_price_buy    =  0;
   open_price_sell   =  0;

   account_balance_0 = AccountBalance();

   return(0);
  }

//+------------------------------------------------------------------+
//|                        DEINIT                                    |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }

//+------------------------------------------------------------------+
//|                        START                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   double spread =  (Ask - Bid ) * 10000;
   
   int buy, sell, monat;
   
   monat = Month( );
   

   
   //int madre1 = tendencia(1440, i_art_madre, i_multi_madre );
   //int madre2 = tendencia(240, i_art_madre, i_multi_madre );
   if ( Close[0] < iMA(NULL, 0, 200, 0, MODE_EMA, 0, 0 )&&
        Close[1] < iMA(NULL, 0, 200, 0, MODE_EMA, 0, 1 )&&
        Close[2] < iMA(NULL, 0, 200, 0, MODE_EMA, 0, 2 )&&
        Close[3] < iMA(NULL, 0, 200, 0, MODE_EMA, 0, 3 )&&
        Close[4] < iMA(NULL, 0, 200, 0, MODE_EMA, 0, 4 ) ){
   
  
       int tendenciaMain = tendencia(0, i_atr, i_multi);
       int tendencia2 = tendencia(0, i_atr-1, i_multi);
       int tendencia3 = tendencia(0, i_atr-2, i_multi);
       int tendencia4 = tendencia(0, i_atr-3, i_multi);
           

                     if (   tendenciaMain == -1 && tendencia2 == -1 && tendencia3 == -1 && tendencia4 == -1  ) {
                
                             getSell();     
                     
                     }      
                     
          if ( tendenciaMain == 1 ) apaga_venta = 0;              
     
     
  } else {
  
    //apaga_venta = 0; 
  
  }  
  
    setModify(  );
 
    account_balance_1 = AccountBalance();
    account_equity = AccountEquity();
    account_difference = account_equity - account_balance_1;
    account_profit = account_balance_1 - account_balance_0;


    Comment("===========================================================\n",
            "VERSION V002 \n",
            "===========================================================\n",


            "Spread : " , spread, "  \n",
            //"Tendencia Madre 1 dia : " , madre1, " \n", 
           // "Tendencia Madre 4 horas : " , madre2, " \n",
            "Apagaga venta : ", apaga_venta , "\n",
            "Account Balance initial : " , account_balance_0, "\n", 
            "Account balance current : " , account_balance_1, "\n", 
            "Account Equity : ", account_equity, "\n", 
            "Account difference: " , account_difference, "\n", 
            "Profit EUR: ", account_profit , "\n",
            "Monat: ", monat, "\n",
            "Jahr : ", Year( ), "\n",
            "PARAMETROS: ---------------- \n",
            "ATR : ", i_atr , "\n", 
            "Multiplier : " , i_multi, "\n",
  
            "===========================================================\n");
    

   return (0);

  }


//+------------------------------------------------------------------+
//|                        BUY                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getBuy()
  {
   if(OrdersTotal()==0)
     {
     
     for( int i = 0; i < iter; i++ ){
        
      //OrderSend(Symbol(),OP_BUY,i_hebelung,Ask,3,Ask-i_stoploss*Point,Ask+i_takeprofit*Point,"Buy", _MagicNumber,0,Blue);
      OrderSend(Symbol(),OP_BUY,i_hebelung,Ask,3,0,0,"Buy", _MagicNumber,0,Blue);
      open_price_buy = OrderOpenPrice();
      flag_close        =  0;
      apaga_compra   = 1;
      apaga_venta    = 0;
      //limpiamos las variables que se usan para abbrir operaciones en retrocesos
      stopsell1 = 0;
      stopsell2 = 0;
     
     
     }
  }
}
//+------------------------------------------------------------------+
//|                        SELL                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getSell()
  {
   if(OrdersTotal()==0){
   
     for( int i = 0; i < iter; i++ ){
        
         OrderSend(Symbol(),OP_SELL,i_hebelung,Bid,3,Bid+i_stoploss*Point,Bid-i_takeprofit*Point,"Sell", _MagicNumber,0,Red);
         //OrderSend(Symbol(),OP_SELL,i_hebelung,Bid,3,0,0,"Sell", _MagicNumber,0,Red);
         open_price_sell = OrderOpenPrice();
         flag_close        =  0;
       
         apaga_venta    = 1;
         //limpiamos las variables que se usan para abbrir operaciones en retrocesos
         stopbuy1 = 0;
         stopbuy2 = 0;
        
      }
  }

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int tendencia(int timeFrame, int atrPeriodo, double multipler)
  {

   int limit, i, flag, flagh, trend[500], tendencia;

   double up[500], dn[500], medianPrice, atr;
//IndicatorCounted() => The amount of bars not changed after the indicator had been launched last.
   int counted_bars = IndicatorCounted();
//---- check for possible errors
//  if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0)
      counted_bars--;
//Bars => Number of bars in the current chart

   limit= iBars(NULL, timeFrame) -1-counted_bars;

   for(i = iBars(NULL, timeFrame) ; i >= 1; i--)
     {

      TrendUp[i] = EMPTY_VALUE;

      TrendDown[i] = EMPTY_VALUE;

      //-------------------------------------------------------------------------

      atr = iATR(NULL, timeFrame, atrPeriodo, i);

      medianPrice = (iHigh(NULL, timeFrame, i) + iLow(NULL, timeFrame, i))/2;

      up[i]=medianPrice+(multipler*atr);

      dn[i]=medianPrice-(multipler*atr);

      if(iClose(NULL, timeFrame, i) > up[i+1])
        {

         trend[i]=1;

        }

      else
         if(iClose(NULL, timeFrame, i) < dn[i+1])
           {

            trend[i]=-1;

           }

         else
            if(trend[i+1]==1)
              {

               trend[i]=1;

              }

            else
               if(trend[i+1]==-1)
                 {

                  trend[i]=-1;

                 }

      ///---------------------------------------------------------
      if(trend[i]<0 && trend[i+1]>0)
        {

         flag=1;

        }
      else
        {

         flag=0;

        }

      if(trend[i]>0 && trend[i+1]<0)
        {

         flagh=1;

        }
      else
        {

         flagh=0;

        }

      if(trend[i]>0 && dn[i]<dn[i+1])

         dn[i]=dn[i+1];

      if(trend[i]<0 && up[i]>up[i+1])

         up[i]=up[i+1];

      if(flag==1)

         up[i]=medianPrice+(multipler*atr);

      if(flagh==1)

         dn[i]=medianPrice-(multipler*atr);

      //-- Draw the indicator
      if(trend[i]==1)
        {

         // TrendUp[i]=dn[i];

         tendencia = 1;

        }
      else
         if(trend[i]==-1)
           {

            // TrendDown[i]=up[i];
            tendencia = -1;

           }

      //----------------------------------------------------------------------------

     }


   return tendencia;

  }



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//|                        MODIFY                                    |
//+------------------------------------------------------------------+

void setModify( ){

   int _GetLastError=0,_OrdersTotal=OrdersTotal(); 
            
            //---- buscamos en todas las posiciones abiertas
            for(int i=OrdersTotal( )-1; i>=0; i --)
            {
            
                  // si ocurre algún error al encontrar la posición, vamos a la siguiente
                  if(!OrderSelect(i,SELECT_BY_POS))
                  {
                     _GetLastError=GetLastError();
                     Print("OrderSelect( ",i,", SELECT_BY_POS ) - Error #",
                           _GetLastError);
                     continue;
                   }
            
                  // si la posición se abrió, pero no para el símbolo actual, 
                  // la saltamos
               
                  if(OrderSymbol()!=Symbol()) continue;
                
                  // si MagicNumber no es igual a _MagicNumber, saltamos 
                  // esta posición
                  //if(OrderMagicNumber()!=_MagicNumber) continue;
                  
                  if(OrderType()==OP_BUY)
                  {
                  
                   /* double difference_buy = OrderOpenPrice()- MarketInfo(Symbol(), MODE_ASK);         
            
                    if(difference_buy >= ( i_takeprofit ) * Point && stopbuy1 == 0 ){ OrderSend(Symbol(),OP_BUY,i_hebelung,Ask,3,Ask-i_stoploss*Point,Ask+(i_takeprofit*2) *Point,"Buy", _MagicNumber,0,Blue); stopbuy1 = 1; } 
                    if(difference_buy >= ( i_takeprofit * 2 ) * Point && stopbuy2 == 0 ){ OrderSend(Symbol(),OP_BUY,i_hebelung,Ask,3,Ask-i_stoploss*Point,Ask+(i_takeprofit*3) *Point,"Buy", _MagicNumber,0,Blue); stopbuy2 = 1; }//80
                    
  
                    */
                     
                     //si se da la condicion para salir------------------------------
                     //if ( tendencia == -1 )
                     //{
                    //    CloseBuyPositions( i );
                    // }//--------------------------------------------------------------
                     
                  }
                  
             //===========================================================================================================================
             //si se abre una posicion sell, como cerrarla
             //===========================================================================================================================
             
                if(OrderType()==OP_SELL)
                {
                    double difference_sell = OrderOpenPrice() - MarketInfo(Symbol(), MODE_BID);  
                    
                    //Negativo
       
                    if(difference_sell > 50 * Point && difference_sell < 70 * Point ){ ModSL( OrderOpenPrice()-20*Point); }
                    if(difference_sell > 100 * Point && difference_sell < 105 * Point ){ ModSL( OrderOpenPrice()-60*Point); }
                    if(difference_sell > 150 * Point && difference_sell < 180 * Point){ ModSL( OrderOpenPrice()-110*Point); }
                    if(difference_sell > 250 * Point && difference_sell < 280 * Point){ ModSL( OrderOpenPrice()-210*Point); }
                    if(difference_sell > 350 * Point && difference_sell < 380 * Point){ ModSL( OrderOpenPrice()-310*Point); }
                    if(difference_sell > 450 * Point && difference_sell < 480 * Point){ ModSL( OrderOpenPrice()-410*Point); }
                    if(difference_sell > 550 * Point && difference_sell < 580 * Point){ ModSL( OrderOpenPrice()-510*Point); }
                    if(difference_sell > 650 * Point && difference_sell < 680 * Point){ ModSL( OrderOpenPrice()-610*Point); }
                    if(difference_sell > 750 * Point && difference_sell < 780 * Point){ ModSL( OrderOpenPrice()-710*Point); }
                    if(difference_sell > 850 * Point && difference_sell < 880 * Point){ ModSL( OrderOpenPrice()-810*Point); }
                    if(difference_sell > 950 * Point && difference_sell < 980 * Point){ ModSL( OrderOpenPrice()-910*Point); }
                   

                     //si se da la condicion para salir------------------------------
                    // if (  tendencia == 1 )
                    // {
                        
                    //    CloseSellPositions( i );
                        
                    // }//--------------------------------------------------------------
                    
                }      
            
          }
           

}//end getClose())

////////////////////////////////////////////////////////////////////////////////////////////////
//Close Buy Operations
void CloseBuyPositions( int i ){
   
   //for ( int i = OrdersTotal( )-1; i >= 0; i-- ){
   
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES);
      
      string CurrencyPair = OrderSymbol( );
      
      if ( _Symbol == CurrencyPair && OrderType( ) == OP_BUY ){
      
            OrderClose(OrderTicket(), OrderLots(), Bid, 3, NULL) ;
      }   
   //}
}

////////////////////////////////////////////////////////////////////////////////////////////////
//Close Sell Operations
void CloseSellPositions( int i ){
   
  // for ( int i = OrdersTotal( )-1; i >= 0; i-- ){
   
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES);
      
      string CurrencyPair = OrderSymbol( );
      
      if ( _Symbol == CurrencyPair && OrderType( ) == OP_SELL ){
      
            OrderClose(OrderTicket(), OrderLots(), Ask, 3, NULL) ;
      }   
   //}
}




//stop loss modification function
void ModSL(double ldSL){
bool fm;
fm=OrderModify(OrderTicket(),OrderOpenPrice(), ldSL ,OrderTakeProfit(),0,Red);
}

void ModTP(double TP){
bool fm;
fm=OrderModify(OrderTicket(),OrderOpenPrice(), OrderStopLoss() ,TP,0,Blue);
}