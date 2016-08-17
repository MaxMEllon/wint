typedef enum {NONE, STOCK, HAND, NHAND} Type;
typedef struct {
  Type type;
  int val;
  double exp;
} Cell;
int strategy_main(int hd[], int st[], int sn, int tk, int cg);
int final_final_attack(int hd[], int st[], int sn);
void final_attack(Cell table[][13], int hd[], int st[], int sn);
void exp_table(Cell table[][13], int hd[], int sn);
double exp_flush(Cell table[][13], int sut, int num, int sn);
double exp_pair(Cell table[][13], int sut, int num, int sn);
double exp_straight(Cell table[][13], int sut, int num, int sn);
double exp_sflush(Cell table[][13], int sut, int num, int sn);
double exp_rsflush(Cell table[][13], int sut, int num, int sn);
void simulate_table(Cell table[][13], int hd[], int st[], int sn, int cg);
int decide_hand(Cell table[][13], int hd[]);
double ave_exp(Cell table[][13], int hd[]);
void init_table(Cell table[][13], int hd[], int st[], int sn, int tk);
void create_stock(int st[], int sn, int hd[], int ud[], int us);
void output_table(Cell table[][13]);
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
int strategy_main(int hd[], int st[], int sn, int tk, int cg)
{
  Cell table[4][13] = {0};
  double ave;
  if ( CHNG >= sn ) { return final_final_attack(hd, st, sn); }
  init_table(table, hd, st, sn, tk);
  exp_table(table, hd, sn);
  ave = ave_exp(table, hd);
  if ( tk == 0 && ave < 2.55 ) { return -1; }
  if ( tk == 1 && ave < 2.5 ) { return -1; }
  if ( tk == 2 && ave < 1.37 && sn <= 33 ) { return -1; }
  if ( tk == 3 && ave < 3.1 && sn <= 22 ) { return -1; }
  if ( tk == 4 && ave < 7.25 && sn <= 11 ) { return -1; }
  if ( tk == 5 ) { final_attack(table, hd, st, sn); }
  return decide_hand(table, hd);
}
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
void final_attack(Cell table[][13], int hd[], int st[], int sn)
{
  int k1, k2;
  double min = INT_MAX;
  int sub = -1;
  Cell tmp[4][13] = {0};
  init_table(tmp, hd, st, sn, -1);
  exp_table(tmp, hd, sn);
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 13; k2++ ) {
      table[k1][k2].exp += tmp[k1][k2].exp;
    }
  }
}
void exp_table(Cell table[][13], int hd[], int sn)
{
  int sut, num;
  int k;
  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k]/13; num = hd[k]%13;
    table[sut][num].exp += exp_flush(table, sut, num, sn);
    table[sut][num].exp += exp_pair(table, sut, num, sn);
    table[sut][num].exp += exp_straight(table, sut, num, sn);
    table[sut][num].exp += exp_sflush(table, sut, num, sn);
    table[sut][num].exp += exp_rsflush(table, sut, num, sn);
  }
}
double exp_flush(Cell table[][13], int sut, int num, int sn)
{
  int k;
  int val = 0;
  double base = 1;
  int cnt = 0;
  int flush_num = HNUM;
  for ( k = 0; k < 13; k++ ) {
    if ( table[sut][k].type == HAND ) { cnt++; }
    else if ( table[sut][k].type == NHAND ) { cnt++; }
    else { val += table[sut][k].val; }
  }
  for ( k = flush_num-cnt; k > 0; k-- ) {
    base *= (double)val/sn;
    val--;
  }
  return base * P5;
}
double exp_pair(Cell table[][13], int sut, int num, int sn)
{
  int k;
  int val = 0;
  double base = 1;
  double exp = 0;
  int cnt = 0;
  int point[] = {P0, P1, P3, P7};
  int point_num = 4;
  for ( k = 0; k < 4; k++ ) {
    if ( table[k][num].type == HAND ) { cnt++; }
    else if ( table[k][num].type == NHAND ) { cnt++; }
    else { val += table[k][num].val; }
  }
  for ( k = 0; k < point_num; k++ ) {
    if ( k >= cnt ) { base *= (double)val/sn; val--; }
    exp += base*point[k];
  }
  return exp;
}
double exp_straight(Cell table[][13], int sut, int num, int sn)
{
  int k, k1, k2;
  double exp = 0;
  int cnt = 0;
  int s_num = HNUM;
  int s, e;
  for ( k = 0; k < 4; k++ ) {
    if ( table[k][num].type == HAND ) { cnt++; }
  }
  if ( cnt > 1 ) { return 0; }
  s = (num-s_num+1 < 0) ? 0 : num-s_num+1;
  e = (num+s_num-1 > 13) ? 13 : num+s_num-1;
  for ( k1 = s; k1 <= num; k1++ ) {
    int i = k1;
    double tmp = 1;
    while ( i < k1+s_num && i <= e ) {
      int val = 0;
      for ( k2 = 0; k2 < 4; k2++ ) {
        if ( table[k2][i%13].type == HAND ) { val = sn; break; }
        else if ( table[k2][i%13].type == NHAND ) { val = sn; break; }
        else { val += table[k2][i%13].val; }
      }
      tmp *= (double)val/sn;
      i++;
    }
    exp += tmp * P4;
  }
  return exp;
}
double exp_sflush(Cell table[][13], int sut, int num, int sn)
{
  int k1, k2;
  double exp = 0;
  int s_num = HNUM;
  int s, e;
  s = (num-s_num+1 < 0) ? 0 : num-s_num+1;
  e = (num+s_num-1 > 13) ? 13 : num+s_num-1;
  for ( k1 = s; k1 <= num; k1++ ) {
    int i = k1;
    double base = 1;
    int val = 0;
    int cnt = 0;
    while ( i < k1+s_num && i <= e ) {
      if ( table[sut][i%13].type == HAND ) { cnt++; }
      else if ( table[sut][i%13].type == NHAND ) { cnt++; }
      else { val += table[sut][i%13].val; }
      i++;
    }
    for ( k2 = s_num-cnt; k2 > 0; k2-- ) {
      base *= (double)val/sn;
      val--;
    }
    exp += base * P8;
  }
  return exp;
}
double exp_rsflush(Cell table[][13], int sut, int num, int sn)
{
  int k;
  int s_num = HNUM;
  double base = 1;
  int val = 0;
  int cnt = 0;
  if ( num < 9 && num != 0 ) { return 0; }
  for ( k = 9; k <= 13; k++ ) {
    if ( table[sut][k%13].type == HAND ) { cnt++; }
    else if ( table[sut][k%13].type == NHAND ) { cnt++; }
    else { val += table[sut][k%13].val; }
  }
  for ( k = s_num-cnt; k > 0; k-- ) {
    base *= (double)val/sn;
    val--;
  }
  return base * P9;
}
void simulate_table(Cell table[][13], int hd[], int st[], int sn, int cg)
{
  int k1, k2;
  if ( sn <= 1 || cg >= 5 ) { return; }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    int t = hd[k1];
    double exp = 0;
    for ( k2 = 0; k2 < sn; k2++ ) {
      Cell tmp[4][13] = {0};
      hd[k1] = st[k2];
      arr_swap(st, 0, k2);
      init_table(tmp, hd, &st[1], sn-1, -1);
      exp_table(tmp, hd, sn-1);
      simulate_table(tmp, hd, &st[1], sn-1, cg+1);
      exp += ave_exp(tmp, hd);
      arr_swap(st, k2, 0);
    }
    hd[k1] = t;
    table[t/13][t%13].exp -= exp / (sn-1);
  }
}
int decide_hand(Cell table[][13], int hd[])
{
  int sut, num;
  int k;
  int sub = -1;
  double min_exp = INT_MAX;
  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k] / 13;
    num = hd[k] % 13;
    if ( min_exp > table[sut][num].exp ) {
      min_exp = table[sut][num].exp;
      sub = k;
    }
  }
  return sub;
}
double ave_exp(Cell table[][13], int hd[])
{
  int k;
  double exp = 0;
  int sut, num;
  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k] / 13;
    num = hd[k] % 13;
    exp += table[sut][num].exp;
  }
  return exp / HNUM;
}
void init_table(Cell table[][13], int hd[], int st[], int sn, int tk)
{
  int k;
  int sut, num;
  int type = (tk == TAKE-1) ? NHAND : STOCK;
  int val = (tk == TAKE-1) ? sn : 1;
  for ( k = 0; k < sn; k++ ) {
    sut = st[k] / 13;
    num = st[k] % 13;
    table[sut][num].type = type;
    table[sut][num].val = val;
  }
  for ( k = 0; k < HNUM; k++ ) {
    sut = hd[k] / 13;
    num = hd[k] % 13;
    table[sut][num].type = HAND;
    table[sut][num].val = sn;
  }
}
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
void output_table(Cell table[][13])
{
  int k1, k2;
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 13; k2++ ) {
      printf("%d", table[k1][k2].type);
      printf("%6.3f", table[k1][k2].exp);
      printf("|");
    }
    puts("");
  }
}