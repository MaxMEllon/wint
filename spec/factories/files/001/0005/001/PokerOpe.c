//====================================================================
//  前処理
//====================================================================

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "Poker.h"

//--------------------------------------------------------------------
//  関数宣言
//--------------------------------------------------------------------
int Four_of_a_kind( const int hd[], int cg, int us  );   // フォーカード
int Straight( const int hd[], int cg, int us  );         // ストレート
int Full_house( const int hd[], int cg, int us  );       // フルハウス
int Flush( const int hd[], int cg, int us );             // フラッシュ

int Three_of_a_kind( const int hd[], int cg, int us  );  // スリーカインズ
int Two_pair( const int hd[], int cg, int us  );         // ツーペア
int One_pair( const int hd[], int cg, int us  );         // ワンペア
int Final( const int hd[], int cg, int us  );            // 6回目用

int Combi( int a, int b );                       // Combinationを求める関数
int Permu( int a, int b );                       // Permutationを求める関数
int Reach_check( void );                         // リーチ判定
void Separate_hand( const int hd[] );            // 手札を 元, 商, 剰余 に分割    
void Separate_dishand( const int ud[], int us ); // 捨て札を 元, 商, 剰余 に分割
void Check_len( void );                          // 連の長さを調べる
void Init_flg( void );                           // フラグの初期化
//====================================================================
//  戦略
//====================================================================

/*--------------------------------------------------------------------
//  ユーザ指定
//--------------------------------------------------------------------

最初の手札のまま交換しない。

hd : 手札配列
fd : 場札配列(テイク内の捨札)
cg : チェンジ数
tk : テイク数
ud : 捨札配列(過去のテイクも含めた全ての捨札)
us : 捨札数

--------------------------------------------------------------------*/
  struct card{
    int orig;   // 元の手札番号
    int mark;   // 手札のマーク
    int num;    // 手札の数字
  };
  struct card hand[6] = {0};       // 手札 リーチ判定用に1つ余分あり
  struct card dishand[52] = {0};   // 捨て札

  int sut[4]   ={0};       // 種類ごとの個数を格納する配列(SHDC) (手札)
  int Num[14]  ={0};       // 数位ごとの個数を格納する配列(1,2,3,4,5,6,7,8,9,T,J,Q,K,A) (手札)
  int udsut[4] ={0};       // 種類ごとの個数を格納する配列(SHDC) (捨て札)
  int udNum[13]={0};       // 数位ごとの個数を格納する配列(1,2,3,4,5,6,7,8,9,T,J,Q,K) (捨て札)
  int flg[15]  ={0};       // フラグ管理  flg[14]はAのかわり flg[0]はKのかわり
  int count = 0;           // カウント用
  int deck_flg[52] = {0};  // 山札の残りを調べる 1は既に出た 0はまだ出ていない
  int ch = 0;              // リーチ判定 結果
  
  
int strategy( const int hd[], const int fd[], int cg, int tk, const int ud[], int us) {
  int i     ;    // 反復変数
  int ret = -1;  // 交換する手札
  
  Separate_hand( hd );
  Separate_dishand( ud, us );


//=========== デッキの残りを sut,num に分ける前の 元の数字 で調べる ==================
  for( i=0; i<52; i++){ deck_flg[i] = 0; }         // フラグの初期化
  for( i=0; i<us; i++){ deck_flg[ud[i]] = 1; }     // 捨て札から 山札候補を見つける
  for( i=0; i<HNUM; i++ ){ deck_flg[hd[i]] = 1; }  // 手札から   山札候補を見つける
  
  /* テイクは0-5まで */
  ch = Reach_check();                 // 中で Check_len(); を呼び出している

  if( tk < 2 ){                       // 1回目と2回目のゲームは捨てる  ただし、リーチの場合は続ける    
    if( ch == 1 ){          // ストレートへ
//      return Straight(hd,cg,us);
      return Flush(hd,cg,us);
    }else if( ch == 2 ){    // フラッシュへ
      return Flush(hd,cg,us);
    }else{                            
      return -1;
    }
  }

  if( tk == 3 && 52-HNUM-us <= 22) { return -1; }
  if( tk == 5 ){ ret = Final(hd,cg,us); }
  if( ret == -1 ){ ret = Flush(hd,cg,us); }  // 返却値は必ず 0-4 の値

  return ret;

}
//====================================================================
//  補助関数
//====================================================================
//=========================================================
//    フォーカード ( P7  64点 )                            
//=========================================================
int Four_of_a_kind( const int hd[], int cg, int us ){
  int i, j;                     // 反復変数
  int num_min;                  // とりあえず宣言しただけなので使うときに確認を！
  int target;                   // 対象とする数字
  struct card  deck[13] = {0};  // 山札の構造体
  int ret  = -1;
  int ret2 = -1;
  int tmp1 = -1, tmp2 = -1;
  
  if( poker_point(hd) > P7 ){ return -1; }  
  
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }    // (手札と捨て札から)山札の数字の残り数を求める

  // ここに来たときは既に3枚1組がある状態 で進めていく
  
  // 対象となる数字を見つける
  for( i=0; i<13; i++ ){
    if( Num[i] == 3 ){
      target = i;
    }
  }
   
  // 山札に必要な残りの数字が有るか確認 なければフルハウスへ変更
  if(  deck[target].num < 1 ){ return Full_house(hd,cg,us); }
  
  
  for( i=0; i<13; i++ ){                  // フォーカードができると仮定して 捨てる 1組 or 2組 の数字を探す
    if( Num[i] == 1 || Num[i] == 2 ){
      tmp1 = i;
      for( j=i+1; j<13; j++){
        if( Num[j] == 1 || Num[j] == 2 ){
          tmp2 = j;
          break;
        }
      }
    }
  }
  
  if( tmp2 != -1 ){
    if( deck[tmp1].num < deck[tmp2].num ){                       // 山札に残っている数字の枚数が少ない方を捨てる
      ret =tmp1;
    }else if( deck[tmp2].num < deck[tmp2].num ){
      ret = tmp2;
    }else if( deck[tmp1].num == deck[tmp2].num ){
      if( deck[hand[tmp1].mark].mark < deck[hand[tmp2].mark].mark ){  // 山札に少ないマークを捨てる
        ret = tmp1;
      }else{
        ret = tmp2;
      }
    }
    for( i=0; i<HNUM; i++ ){
      if( hand[i].num == ret ){ return i; }
    }
  }else { // tmp2 = -1 のとき すなわち 2枚1組だった場合 （AAA55）など
    for( i=0; i<HNUM; i++ ){
      if( hand[i].num =! target ){
        for( j=i+1; j<HNUM; j++ ){
          if( hand[i].num != target ){
            if( deck[hand[i].mark].mark < deck[hand[j].mark].mark ){  // 山札に少ないマークを捨てる
              return i;
            }else{
              return j;
            }
          }
        }
      }
    }
  }
  /* 手札から数字を探す */
  
  return ret2;
}

//=========================================================
//    ストレート ( P4  32点 )     A23456789TJQKA       
//=========================================================
/*
    i|0 1 2 3 4 5 6 7 8 9 10 11 12  13
    -----------------------------------
     |A 2 3 4 5 6 7 8 9 T  J  Q  K  A
*/     
int Straight( const int hd[], int cg, int us ){
  int i, j,k;                  // 反復変数
  int a,b,c;                   // 計算に使う一時変数
  int chng=-1;                 // 交換するnum
  int ret = -1;
  struct card  deck[14] = {0}; // 山札の構造体
  double deck_pro[14] = {0};   // デッキからストレートのできる各々のnumの確率 deck_pro[0] = A = deck_pro[13]
  double hand_pro[13] = {0};   // 手札のカードの確率
  double min =100;
  int count = 0;
  int tmp1, tmp2;
  
  if( poker_point(hd) >= P4 ){ return -1; }
/*----- 事前処理--------------------- -------------------- */
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }    // (手札と捨て札から)山札の数字の残り数を求める
  deck[13].num = deck[0].num;
  
  //------------------------ 手札に同じ数字がある場合、山札に多い方を残す
  for( i=0; i<4; i++ ){
    if( 1 < Num[i] ){           // 同じ数字が2枚ある場合
      for( j=0; j<HNUM; j++){
        if( hand[j].num == i ){  tmp1 = j; break;}         // 数字からマークを調べる
      }
      for( k=0; k<HNUM; k++){
        if( hand[k].num == i && tmp1 != k ){ tmp2 = k; }   // 数字からマークを調べる
      }
      if( deck[tmp1].num < deck[tmp2].num ){               // 手札の tmp1 番目 と tmp2 番目が同じ数字 残りマークの少ない方を捨てる
        return tmp1;
      }else{
        return tmp2;
      }
    }
  }

  //------------------------
  for( i=0; i<HNUM; i++ ){
    for( j=0; j<14; j++ ){
      if( hand[i].num != j && flg[j] != -1 ){    // 手札にあるものは -1 とする
        flg[j] = deck[j].num;
      }else{
        flg[j] = -1;
      }
    }
  }
  flg[13] = flg[0];


  for( i=0; i<14-4; i++ ){          // 5つの塊で見ていく
    a = 1;
    count = 0;
    for( j=i; j<i+HNUM; j++ ){
      if( flg[j] != -1 && flg[j] != 0 ){  // 手札にない かつ 山札の枚数が 0でない
        a *= flg[j];          // 手札にないカードについて確率の一部分を求める
        count++;
      }
    }
    b = Permu( (52-HNUM-us)-count, count);
    c = Permu( 52-HNUM-us, CHNG-cg );
    
    for( k=i; k<i+HNUM; k++ ){
      deck_pro[k]   += (double)(a*b)/c;
    }  
  }    
  deck_pro[0] += deck_pro[13];  // AとKの後のAは同じため
    

  // 捨てる捜索範囲は i=0 i<13 まで 仮想Aは 含めない
  // 手札の番号について確率を格納し、その5つの中から比較する。
  for( i=0; i<13; i++ ){
    for( j=0; j<HNUM; j++ ){
      if( i == hand[j].num ){
        hand_pro[i] = deck_pro[i];
      }
    }
  }

  
  // 確率が最小のものを探す。
  for( i=0; i<13; i++ ){
    if( hand_pro[i] < min && hand_pro[i] != 0 ){
      min = hand_pro[i];
      chng = i;
    }
  }

  // 手札から交換対象 chng を探す
  for( i=0; i<HNUM; i++ ){
    if( hand[i].num == chng ){
      ret = i;
    }
  }
  
  return ret;
}
//*/

//=========================================================
//    フラッシュ ( P5  24点 )                              
//=========================================================
int Flush( const int hd[], int cg, int us ){
  int target;                 // 対象とするマーク(SHDC)
  struct card  deck[13] = {0};// 山札の構造体
  double Mark[4] = {0};       // 各マークの出る確率(0=S 1=H 2=D 3=C)
  double hand_pro[5] = {0};   // 各手札のマークの出る確率(1枚目,2枚目,...)
  double min = 1;             // 最小値を格納
  int chng_mark = 0;          // 捨てるマーク
  int sut_max = 0;            // 手持ちカードの最大組のマークを示す
  int ret=0;                  // 交換するカード
  int i, j;                   // 反復変数
  int a, b;                   // 一時変数
  
  if( poker_point(hd) >= P5 ){ return -1; }
  
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  
  for( i=0; i<HNUM; i++ ){
    if( CHNG-cg < HNUM-sut[i] || deck[hand[i].mark].mark == 0 ){ // 残りチェンジ数が必要枚数よりも多い場合 か 山札に対象マークカードがない
      hand_pro[i] = 0;
    }else{
      a = Combi( deck[hand[i].mark].mark, HNUM - sut[hand[i].mark] );  // 13C4 など 13枚のうち、5枚に足りない4枚が出る確率を求める
      b = Combi( (52-us-HNUM), HNUM - sut[hand[i].mark] );             // 山札の中から 5枚に足りない4枚が出る確率を求める
      hand_pro[i] = (double)a/b;
    }
  }
  
  for( i=0; i<4; i++ ){       // 手札の中からマークの数が最大の物を探す
    if( sut_max < sut[i] ){
      sut_max = sut[i];
      target = i;
    }
  }

  if( sut[target] == 2 || sut[target] == 3 || sut[target] == 4 ){  // 既に出来ているペアは(確率を最大にして)崩さない
    for( j=0; j<HNUM; j++ ){
      if( hand[j].mark == target ){
        hand_pro[j] = 1.0;
      }
    }
  }

  for( i=0; i<HNUM; i++ ){  // 出る確率の低いマークを探す
    if( hand_pro[i] < min ){ min = hand_pro[i]; chng_mark = i; }
  }
  ret = chng_mark;

  return ret;
}
//=========================================================
//    フルハウス ( P6  16点 )                          
//=========================================================
int Full_house( const int hd[], int cg, int us ){
  int i, j, k;                // 反復変数
  int a, b;
  int ret = -1;
  double hand_pro[5] = {0};
  double min = 1;
  int chng_num = 0;
  struct card  deck[13] = {0};// 山札の構造体

  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }    // (手札と捨て札から)山札の数字の残り数を求める

  if( poker_point(hd) > P6 ){ return -1; }  /* 2ペア,3ペアが既に揃っている */
  if( poker_point(hd) == P0){ One_pair(hd,cg,us); } // ワンペアもできていない
  if( poker_point(hd) == P1){ Two_pair(hd,cg,us); } // ツーペアもできていない
  
  /*  以下は2ペア以上ができていれば入る */
  /*----- 既に 3枚揃っている場合 (ただ、 ツーペア以下は無視 より無意味)--------------- */
//*
  for( i=0; i<13; i++ ){
    if( Num[i] == 3 ){               // 1組目(i番目)が 3枚ある
      for( k=0; k<HNUM; k++ ){
        if( hand[k].num != i ){  // 手札中の 3枚セットの数字以外の手札を交換
          hand_pro[k] = (double)deck[hand[k].num].num/(52-us-HNUM);
        }else{
          hand_pro[k] = 1.0;
        }
      }
      for( i=0; i<HNUM; i++ ){  // 出る確率の低いマークを探す
        if( hand_pro[i] < min ){ min = hand_pro[i]; chng_num = i; }
      }
      ret = chng_num;
      return ret;
    }
  }

//*/
/*----- 2枚が2組ある場合 -------------------- */  
//*    
  for( i=0; i<13; i++ ){
    if( Num[i] == 2 ){               // 1組目(i番目の数)が 2枚ある
      for( j=i+1; j<13; j++ ){
        if( Num[j] == 2 ){           // 2組目(j番目の数)が 2枚ある
          for( k=0; k<HNUM; k++ ){
            if( hand[k].num != i && hand[k].num != j ){  // 手札中の 1組目 と 2組目 の数字以外の手札を交換
              return k;
            }
          }
        }
      }
    }
  }
  return -1;
}
//=========================================================
//    スリーカインズ ( P3  8点 )                      
//=========================================================
int Three_of_a_kind( const int hd[], int cg, int us ){
  int i, j;    // 反復変数
  
  if( poker_point(hd) > P3 ){ return -1; }

  for( i=0; i<13; i++ ){                  // 2枚1組 の数字を探す
    if( Num[i] == 2 ){ break; }           // i番目の手札が 2枚1組 になっている
  }
  
  for( j=0; j<5; j++ ){                   // 小さい数字から手札の番号を導く
    if( hand[j].num == i ){ return j; }
  }

  return -1;
}    

//=========================================================
//    ツーペア ( P2  2点 )                             
//=========================================================
int Two_pair( const int hd[], int cg, int us ){
  int i, j, k;       // 反復変数
  int ret = -1;
  double hand_pro[5] = {0};
  double min = 1;
  int chng_num = 0;
  struct card  deck[13] = {0};// 山札の構造体

  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }    // (手札と捨て札から)山札の数字の残り数を求める
  
  if( poker_point(hd) > P2 ){ return -1; }
  
  for( i=0; i<13; i++ ){
    if( Num[i] == 2 ){               // i番目が2枚ある
      for( k=0; k<5; k++ ){
        if( hand[k].num != i ){  // 手札中の 2枚セットの数字以外の手札を交換
          hand_pro[k] = (double)deck[hand[k].num].num/(52-us-HNUM);
        }else{
          hand_pro[k] = 1.0;
        }
      }
      for( i=0; i<HNUM; i++ ){  // 出る確率の低いマークを探す
        if( hand_pro[i] < min ){ min = hand_pro[i]; chng_num = i; }
      }
      ret = chng_num;
      return ret;
    }
  }
  return -1;
}   
//=========================================================
//    ワンペア ( P1  1点 )                             
//=========================================================
int One_pair( const int hd[], int cg, int us ){
  int i, j, k, m, s, t;    // 反復変数
  int a,b;
  int ret;
  double hand_pro[5] = {0};
  double min = 1;
  int chng_num = 0;
  struct card  deck[14] = {0};// 山札の構造体

  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }    // (手札と捨て札から)山札の数字の残り数を求める

  for( i=0; i<HNUM; i++ ){ hand_pro[i] = (double)deck[hand[i].num].num/(52-us-HNUM); }

  for( i=0; i<HNUM; i++ ){  // 出る確率の低いマークを探す
    if( hand_pro[i] < min ){ min = hand_pro[i]; chng_num = i; }
  }
  ret = chng_num;
  return ret;
}   
//=========================================================
//    ファイナル                                           
//=========================================================
int Final( const int hd[], int cg, int us  ){
  struct card  deck[13] = {0};       // 山札の構造体
  int i, j, k, l, m, n;              // 反復変数
  int flag[5] = {0};                 // 返却カード管理フラグ
  int max_point = 0;
  struct card  mer_deck[13] = {0};   // 山札と手札を合わせた構造体
  struct card  ideal_hand[5]= {0};   // 理想手札の構造体
  int  vir_hand[5]  = {0};           // 仮想手札の構造体
  int  vir_deck[52] = {0};           // 仮想山札
  int deck_max = 0;                  // 仮想山札の最大数    
  
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }  // (手札と捨て札から)山札のマーク残り数を求める
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }    // (手札と捨て札から)山札の数字の残り数を求める

  for( i=0; i< 4; i++ ){ mer_deck[i].mark = deck[i].mark + sut[i] ; } // 山札と手札を合わせる（マーク）
  for( i=0; i<13; i++ ){ mer_deck[i].num  = deck[i].num  + Num[i] ; } // 山札と手札を合わせる（数字）
  
  for( j=0, i=0; i<52; i++ ){       // 仮想山札に捨て札から計算したカード追加
    if( deck_flg[i] == 0 ){
      vir_deck[j] = i;
      j++;
    }
  }
  
  for( i=0; i<HNUM; i++ ){     // 仮想山札に手札から計算したカード追加
      vir_deck[j] = hand[i].orig;
      j++;
  }
  
//  for( i=0; i<HNUM; i++ ){ printf("hand[%d].orig = %d\n",i ,hand[i].orig ); }
//  for( i=0; i<j; i++ ){ printf("●vir_deck[%d]  = %d\n", i, vir_deck[i] );}
  
  deck_max = j;
  max_point = 0;
  for( i=0; i<deck_max-4; i++ ){
    for( j=i+1; j<deck_max-3; j++ ){
      for( k=j+1; k<deck_max-2; k++ ){
        for( l=k+1; l<deck_max-1; l++ ){
          for( m=l+1; m<deck_max; m++ ){
            vir_hand[0] = vir_deck[i];
            vir_hand[1] = vir_deck[j];
            vir_hand[2] = vir_deck[k];
            vir_hand[3] = vir_deck[l];
            vir_hand[4] = vir_deck[m];
            if( max_point < poker_point(vir_hand) ){
              max_point = poker_point(vir_hand);
              ideal_hand[0].orig = vir_hand[0]; // printf("i=%d  ",i );
              ideal_hand[1].orig = vir_hand[1]; // printf("j=%d  ",j );
              ideal_hand[2].orig = vir_hand[2]; // printf("k=%d  ",k );
              ideal_hand[3].orig = vir_hand[3]; // printf("l=%d  ",l );
              ideal_hand[4].orig = vir_hand[4]; // printf("m=%d  \n",m );
            }
          }
        }
      }
    }
  }

  for( i=0; i<HNUM; i++ ){
    ideal_hand[i].mark = ideal_hand[i].orig/13;
    ideal_hand[i].num  = ideal_hand[i].orig%13;
  }

  /* 仮想手札に近づくように切る(仮想手札以外のものを切る) */
  
  for( i=0; i<HNUM; i++ ){
    for( j=0; j<HNUM; j++ ){
      if( hand[i].orig == ideal_hand[j].orig ){  // 理想手札のi番目と同じものがある = flag = 1
        flag[i] = 1;
      }
    }
  }

  for( i=0; i<HNUM; i++ ){
    if( flag[i] == 0 ){ return i; }
  }
  
  return -1;
}
//=========================================================
//    手札を 元, 商, 剰余 に分割                             
//=========================================================
void Separate_hand( const int hd[] ){
  int i;    // 反復変数

  for( i=0; i< 4; i++){ sut[i] = 0; }
  for( i=0; i<13; i++){ Num[i] = 0; }

  for( i=0; i<5; i++ ){
    hand[i].orig = hd[i];
    hand[i].mark = hd[i]/13;
    hand[i].num  = hd[i]%13;
    sut[hand[i].mark]++;    // 0[S], 1[H], 2[D], 3[C] のいずれかのマークの出現数を格納
    Num[hand[i].num]++;     // 同じ数字の出現数を格納
  }
}

//=========================================================
//    捨て札を 元, 商, 剰余 に分割                             
//=========================================================
void Separate_dishand( const int ud[], int us ){
  int i;    // 反復変数

  for( i=0; i< 4; i++){ udsut[i] = 0; }
  for( i=0; i<13; i++){ udNum[i] = 0; }

  for( i=0; i<us; i++ ){
    dishand[i].orig = ud[i];
    dishand[i].mark = ud[i]/13;
    dishand[i].num  = ud[i]%13;
    udsut[dishand[i].mark]++;    // 0[S], 1[H], 2[D], 3[C] のいずれかのマークの出現数を格納
    udNum[dishand[i].num]++;     // 同じ数字の出現数を格納
  }
}
//=========================================================
//      カードの連の長さを調べる                           
//=========================================================
void Check_len( void ){
  int i;

  count = 0;
  Init_flg();
  
  for( i=1; i<=13; i++ ){
    if( i == 13 ){
      if( Num[0] != 0 ){  // 現在のカードを持っている かつ 1つ前のカードがある。
        count++;
      }else{
        count = 0;
      }
    }else if( Num[i] != 0 ){  // 現在のカードを持っている かつ 1つ前のカードがある。
      count++;
    }else{
      count = 0;
    }
    flg[i] = count;
  }

  // KとAが続いた時の処理  
  if( flg[13] != 0 && flg[1] != 0 ){ flg[0] = flg[13]; flg[1] = flg[13]+1; }
  
}
//=========================================================
//    コンビネーション（組合せ）を求める関数                         
//=========================================================
int Combi( int a, int b ){
  int i;    // 反復変数
  int tmp = 1;
  
  for( i=a; a-b<i; i-- ){ tmp *= i; }
  for( i=b; 0<i; i-- ){ tmp /= i; }

  if( tmp == 0 ){ tmp = 1; }
  return tmp;
}
//=========================================================
//    パーミュテーション（順列）を求める関数                         
//=========================================================
int Permu( int a, int b ){
  int i;     // 反復変数
  int tmp = 1;
  
  for( i=a; a-b<i; i-- ){ tmp *= i; }

  if( a < 0 || b < 0 || tmp == 0 ){ tmp = 1; }
  return tmp;
}
//=========================================================
//    リーチ判定                                           
//=========================================================
int Reach_check( void ){
  // ストレートなら1 フラッシュなら2を返す
  struct card  vir_hand[5]  = {0};   // 仮想手札の構造体
  struct card  vir_deck[52] = {0};   // 仮想山札
  int deck_max;                      // 仮想山札の枚数
  int i,j,k;                         // 反復変数
  int virNum[13] = {0};              // 仮想山札のnum枚数
  
  // ----- 事前処理 ---------------------
  for( j=0, i=0; i<52; i++ ){       // 仮想山札に捨て札から計算したカード追加
    if( deck_flg[i] == 0 ){
      vir_deck[j].orig = i;
      j++;
    }
  }
  
  for( i=0; i<HNUM; i++ ){          // 仮想山札に手札から計算したカード追加
      vir_deck[j].orig = hand[i].orig;
      j++;
  }

  deck_max = j;
  
  for( i=0; i<deck_max; i++ ){
    vir_deck[i].mark = vir_deck[i].orig / 13;
    vir_deck[i].num  = vir_deck[i].orig % 13;
  }
// ---- 仮想山札のnumの枚数を調べる-----------------------
  for( i=0; i<deck_max-5;  i++ ){ virNum[vir_deck[i].num]++; }
  
  // ----- ストレート判定 -------------------
  for( i=0; i<deck_max; i++ ){
    Num[vir_deck[i].num]++;
    Check_len();
    for( j=0; j<14; j++ ){
      if( 4 < flg[j]){
        Num[vir_deck[i].num]--;
        return 1;
      }
    }
    Num[vir_deck[i].num]--;
  }
  
  //------ フラッシュ判定 ------------------
  for( i=0; i<4; i++ ){
    if( 3 < sut[i] ){ return 2; }  // 同じマークが4枚ある
  }
  return -1;
}
//=========================================================
//    フラグの初期化                                       
//=========================================================
void Init_flg( void ){
  int i;
  for( i=0; i<15; i++ ){ flg[i] = 0;}
}
//=========================================================
//    デバッグ用                                           
//=========================================================



