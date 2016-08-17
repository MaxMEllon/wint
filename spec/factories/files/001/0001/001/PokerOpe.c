//====================================================================
//  前処理
//====================================================================

#include <stdio.h>
#include <limits.h>

#include "Poker.h"

#define SUITE 4
#define NUMBER 13

typedef enum {NONE, STOCK, HAND, NHAND} Type;

typedef struct {
  Type type;
  int val;
  double exp;
} Cell;

//--------------------------------------------------------------------
//  関数宣言
//--------------------------------------------------------------------

//--  戦略
int strategy_main(int hd[], int st[], int sn, int tk, int cg);
int final_final_attack(int hd[], int st[], int sn);
void final_attack(Cell table[][NUMBER], int hd[], int st[], int sn);
void exp_table(Cell table[][NUMBER], int hd[], int sn);
double exp_flush(Cell table[][NUMBER], int sut, int num, int sn);
double exp_pair(Cell table[][NUMBER], int sut, int num, int sn);
double exp_straight(Cell table[][NUMBER], int sut, int num, int sn);
double exp_sflush(Cell table[][NUMBER], int sut, int num, int sn);
double exp_rsflush(Cell table[][NUMBER], int sut, int num, int sn);

void simulate_table(Cell table[][NUMBER], int hd[], int st[], int sn, int cg);
int decide_hand(Cell table[][NUMBER], int hd[]);
double ave_exp(Cell table[][NUMBER], int hd[]);

//--  準備系
void init_table(Cell table[][NUMBER], int hd[], int st[], int sn, int tk);
void create_stock(int st[], int sn, int hd[], int ud[], int us);

//--  デバッグ用
void output_table(Cell table[][NUMBER]);

//====================================================================
//  Poker戦略AI
//====================================================================

/*--------------------------------------------------------------------
//  ユーザ指定
//--------------------------------------------------------------------

hd : 手札配列
fd : 場札配列(テイク内の捨札)
cg : チェンジ数
tk : テイク数
ud : 捨札配列(過去のテイクも含めた全ての捨札)
us : 捨札数

//----  役の配点
P0    0    // ノーペア
P1    1    // ワンペア
P2    2    // ツーペア
P3    8    // スリーカインズ
P4   32    // ストレート
P5   24    // フラッシュ
P6   16    // フルハウス
P7   64    // フォーカード
P8  128    // ストレートフラッシュ
P9  256    // ロイヤルストレートフラッシュ
--------------------------------------------------------------------*/

int strategy(const int hd[], const int fd[], int cg, int tk, const int ud[], int us)
{
  int myhd[HNUM], myud[CNUM], stock[CNUM];
  int stock_num = CNUM - HNUM - us;

  arr_copy(myhd, hd, HNUM);

  if ( poker_point(myhd) >= P6 ) { return -1; }

  arr_copy(myud, ud, us);
  create_stock(stock, stock_num, myhd, myud, us);

  return strategy_main(myhd, stock, stock_num, tk, cg);
}

//====================================================================
//  補助関数
//====================================================================

//==========================================================
//  戦略
//==========================================================

//----------------------------------------------------------
//  戦略本体
//----------------------------------------------------------
int strategy_main(int hd[], int st[], int sn, int tk, int cg)
{
  Cell table[SUITE][NUMBER] = {0};
  double ave;

  if ( CHNG >= sn ) { return final_final_attack(hd, st, sn); }

  init_table(table, hd, st, sn, tk);
  exp_table(table, hd, sn);

  ave = ave_exp(table, hd);

  if ( tk == 0 && ave < 2.55 ) { return -1; }
  if ( tk == 1 && ave < 2.5 ) { return -1; }
  if ( tk == 2 && ave < 1.37 && sn <= 33 ) { return -1; }
  if ( tk == 3 && ave < 3.1  && sn <= 22 ) { return -1; }
  if ( tk == 4 && ave < 7.25 && sn <= 11 ) { return -1; }
  if ( tk == 5 ) { final_attack(table, hd, st, sn); }

  //if ( ave < 8 ) { simulate_table(table, hd, st, sn, 4); }

  return decide_hand(table, hd);
}

//----------------------------------------------------------
//  最後のファイナルアタック
//----------------------------------------------------------
int final_final_attack(int hd[], int st[], int sn)
{
  int thd[HNUM], mhd[HNUM];
  int k;
  int k1, k2, k3, k4, k5;
  int max = 0;
  int t;

  for ( k = 0; k < HNUM; k++ ) { st[k+sn] = hd[k]; }
  sn += HNUM;

  for ( k1 = 0; k1 < sn-4; k1++ ) {
    thd[0] = st[k1];
    for ( k2 = k1+1; k2 < sn-3; k2++ ) {
      thd[1] = st[k2];
      for ( k3 = k2+1; k3 < sn-2; k3++ ) {
        thd[2] = st[k3];
        for ( k4 = k3+1; k4 < sn-1; k4++ ) {
          thd[3] = st[k4];
          for ( k5 = k4+1; k5 < sn; k5++ ) {
            thd[4] = st[k5];
            t = poker_point(thd);
            if ( t > max ) { max = t; arr_copy(mhd, thd, HNUM); }
          }
        }
      }
    }
  }

  for ( k1 = 0; k1 < HNUM; k1++ ) {
    int flag = 0;
    for ( k2 = 0; k2 < HNUM; k2++ ) {
      if ( hd[k1] == mhd[k2] ) { flag = 1; }
    }
    if ( flag == 0 ) { return k1; }
  }

  return -1;
}

//----------------------------------------------------------
//  ファイナルアタック
//----------------------------------------------------------
void final_attack(Cell table[][NUMBER], int hd[], int st[], int sn)
{
  int k1, k2;
  double min = INT_MAX;
  int sub = -1;
  Cell tmp[SUITE][NUMBER] = {0};

  init_table(tmp, hd, st, sn, -1);
  exp_table(tmp, hd, sn);
  for ( k1 = 0; k1 < SUITE; k1++ ) {
    for ( k2 = 0; k2 < NUMBER; k2++ ) {
      table[k1][k2].exp += tmp[k1][k2].exp;
    }
  }
}

//----------------------------------------------------------
//  評価値テーブルの評価(期待値)
//----------------------------------------------------------
void exp_table(Cell table[][NUMBER], int hd[], int sn)
{
  int sut, num;
  int k;

  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k]/NUMBER; num = hd[k]%NUMBER;
    table[sut][num].exp += exp_flush(table, sut, num, sn);
    table[sut][num].exp += exp_pair(table, sut, num, sn);
    table[sut][num].exp += exp_straight(table, sut, num, sn);
    table[sut][num].exp += exp_sflush(table, sut, num, sn);
    table[sut][num].exp += exp_rsflush(table, sut, num, sn);
  }
}

//----------------------------------------------------------
//  フラッシュ評価(期待値)
//----------------------------------------------------------
double exp_flush(Cell table[][NUMBER], int sut, int num, int sn)
{
  int k;
  int val = 0;
  double base = 1;
  int cnt = 0;
  int flush_num = HNUM;    // フラッシュに必要な枚数

  for ( k = 0; k < NUMBER; k++ ) {
    if ( table[sut][k].type == HAND ) { cnt++; }
    else if ( table[sut][k].type == NHAND ) { cnt++; }
    else { val += table[sut][k].val; }
  }

  //--  確率の算出
  for ( k = flush_num-cnt; k > 0; k-- ) {
    base *= (double)val/sn;
    val--;
  }

  return base * P5;
}

//----------------------------------------------------------
//  ペア評価(期待値)
//----------------------------------------------------------
double exp_pair(Cell table[][NUMBER], int sut, int num, int sn)
{
  int k;
  int val = 0;
  double base = 1;
  double exp = 0;
  int cnt = 0;
  int point[] = {P0, P1, P3, P7};
  int point_num = 4;

  for ( k = 0; k < SUITE; k++ ) {
    if ( table[k][num].type == HAND ) { cnt++; }
    else if ( table[k][num].type == NHAND ) { cnt++; }
    else { val += table[k][num].val; }
  }

  //--  確率の算出
  for ( k = 0; k < point_num; k++ ) {
    if ( k >= cnt ) { base *= (double)val/sn; val--; }
    exp += base*point[k];
  }

  return exp;
}

//----------------------------------------------------------
//  ストレート評価(期待値)
//----------------------------------------------------------
double exp_straight(Cell table[][NUMBER], int sut, int num, int sn)
{
  int k, k1, k2;
  double exp = 0;
  int cnt = 0;
  int s_num = HNUM;    // ストレートに必要な枚数
  int s, e;

  //--  既に同じ数字が2枚以上手札にある場合は期待値0
  for ( k = 0; k < SUITE; k++ ) {
    if ( table[k][num].type == HAND ) { cnt++; }
  }
  if ( cnt > 1 ) { return 0; }

  //--  探索範囲の調整
  s = (num-s_num+1 < 0) ? 0 : num-s_num+1;
  e = (num+s_num-1 > NUMBER) ? NUMBER : num+s_num-1;

  for ( k1 = s; k1 <= num; k1++ ) {
    int i = k1;
    double tmp = 1;
    while ( i < k1+s_num && i <= e ) {
      int val = 0;
      for ( k2 = 0; k2 < SUITE; k2++ ) {
        if ( table[k2][i%NUMBER].type == HAND ) { val = sn; break; }
        else if ( table[k2][i%NUMBER].type == NHAND ) { val = sn; break; }
        else { val += table[k2][i%NUMBER].val; }
      }
      tmp *= (double)val/sn;
      i++;
    }
    exp += tmp * P4;
  }

  return exp;
}

//----------------------------------------------------------
//  ストレートフラッシュ評価(期待値)
//----------------------------------------------------------
double exp_sflush(Cell table[][NUMBER], int sut, int num, int sn)
{
  int k1, k2;
  double exp = 0;
  int s_num = HNUM;    // ストレートフラッシュに必要な枚数
  int s, e;

  //--  探索範囲の調整
  s = (num-s_num+1 < 0) ? 0 : num-s_num+1;
  e = (num+s_num-1 > NUMBER) ? NUMBER : num+s_num-1;

  for ( k1 = s; k1 <= num; k1++ ) {
    int i = k1;
    double base = 1;
    int val = 0;
    int cnt = 0;
    while ( i < k1+s_num && i <= e ) {
      if ( table[sut][i%NUMBER].type == HAND ) { cnt++; }
      else if ( table[sut][i%NUMBER].type == NHAND ) { cnt++; }
      else { val += table[sut][i%NUMBER].val; }
      i++;
    }

    //--  確率の算出
    for ( k2 = s_num-cnt; k2 > 0; k2-- ) {
      base *= (double)val/sn;
      val--;
    }
    exp += base * P8;
  }

  return exp;
}

//----------------------------------------------------------
//  ロイヤルストレートフラッシュ評価(期待値)
//----------------------------------------------------------
double exp_rsflush(Cell table[][NUMBER], int sut, int num, int sn)
{
  int k;
  int s_num = HNUM;    // ロイヤルストレートフラッシュに必要な枚数
  double base = 1;
  int val = 0;
  int cnt = 0;

  //--  圏外
  if ( num < 9 && num != 0 ) { return 0; }

  for ( k = 9; k <= NUMBER; k++ ) {
    if ( table[sut][k%NUMBER].type == HAND ) { cnt++; }
    else if ( table[sut][k%NUMBER].type == NHAND ) { cnt++; }
    else { val += table[sut][k%NUMBER].val; }
  }

  //--  確率の算出
  for ( k = s_num-cnt; k > 0; k-- ) {
    base *= (double)val/sn;
    val--;
  }

  return base * P9;
}

//----------------------------------------------------------
//  評価値テーブルのシミュレート
//----------------------------------------------------------
void simulate_table(Cell table[][NUMBER], int hd[], int st[], int sn, int cg)
{
  int k1, k2;

  if ( sn <= 1 || cg >= 5 ) { return; }

  for ( k1 = 0; k1 < HNUM; k1++ ) {
    int t = hd[k1];
    double exp = 0;
    for ( k2 = 0; k2 < sn; k2++ ) {
      Cell tmp[SUITE][NUMBER] = {0};

      hd[k1] = st[k2];
      arr_swap(st, 0, k2);
      init_table(tmp, hd, &st[1], sn-1, -1);
      exp_table(tmp, hd, sn-1);

      simulate_table(tmp, hd, &st[1], sn-1, cg+1);
      exp += ave_exp(tmp, hd);

      arr_swap(st, k2, 0);
    }
    hd[k1] = t;
    table[t/NUMBER][t%NUMBER].exp -= exp / (sn-1);
  }
}

//----------------------------------------------------------
//  評価値による返却値の確定
//----------------------------------------------------------
int decide_hand(Cell table[][NUMBER], int hd[])
{
  int sut, num;
  int k;
  int sub = -1;
  double min_exp = INT_MAX;

  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k] / NUMBER;
    num = hd[k] % NUMBER;
    if ( min_exp > table[sut][num].exp ) {
      min_exp = table[sut][num].exp;
      sub = k;
    }
  }
  return sub;
}

//----------------------------------------------------------
//  評価値の平均
//----------------------------------------------------------
double ave_exp(Cell table[][NUMBER], int hd[])
{
  int k;
  double exp = 0;
  int sut, num;
  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k] / NUMBER;
    num = hd[k] % NUMBER;
    exp += table[sut][num].exp;
  }
  return exp / HNUM;
}

//==========================================================
//  準備系
//==========================================================

//----------------------------------------------------------
//  評価値テーブルの初期化
//----------------------------------------------------------
void init_table(Cell table[][NUMBER], int hd[], int st[], int sn, int tk)
{
  int k;
  int sut, num;
  int type = (tk == TAKE-1) ? NHAND : STOCK;
  int val = (tk == TAKE-1) ? sn : 1;

  for ( k = 0; k < sn; k++ ) {
    sut = st[k] / NUMBER;
    num = st[k] % NUMBER;
    table[sut][num].type = type;
    table[sut][num].val = val;
  }
  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k] / NUMBER;
    num = hd[k] % NUMBER;
    table[sut][num].type = HAND;
    table[sut][num].val = sn;
  }
}

//----------------------------------------------------------
//  山札の生成
//----------------------------------------------------------
void create_stock(int st[], int sn, int hd[], int ud[], int us)
{
  int i, j, k;
  int s;

  for ( k = 0; k < CNUM; k++ ) { st[k] = k; }
  for ( k = 0; k < HNUM; k++ ) { s = hd[k]; st[s] = -1; }
  for ( k = 0; k < us; k++ ) { s = ud[k]; st[s] = -1; }

  for ( i = 0; i < sn; i++ ) {
    if ( st[i] == -1 ) {
      for ( j = sn; j < CNUM; j++ ) {
        if ( st[j] != -1 ) { arr_swap(st, i, j); break; }
      }
    }
  }
}


//==========================================================
//  デバッグ用
//==========================================================

//----------------------------------------------------------
//  評価値テーブルの表示
//----------------------------------------------------------
void output_table(Cell table[][NUMBER])
{
  int k1, k2;
  for ( k1 = 0; k1 < SUITE; k1++ ) {
    for ( k2 = 0; k2 < NUMBER; k2++ ) {
      printf("%d", table[k1][k2].type);
      //printf(" %2d", table[k1][k2].val);
      printf("%6.3f", table[k1][k2].exp);
      printf("|");
    }
    puts("");
  }
}


