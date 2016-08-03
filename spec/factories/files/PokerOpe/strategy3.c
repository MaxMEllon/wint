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

int staright_h(const int hd[], const int num[]);
int flash_h(const int sut[], const int hd[], int usut[]);
int fullhouse_h(const int num[], const int hd[]);
int pair_h(const int num[], const int hd[], int unum[]);

//====================================================================
//  戦略
//====================================================================

/*--------------------------------------------------------------------
//  ユーザ指定
//--------------------------------------------------------------------

最初の手札のまま交換しない。

hd : 手札配列
fd : 場札配列(テイク内の捨札)
cg : チェンジ数 6
tk : テイク数 6
ud : 捨札配列(過去のテイクも含めた全ての捨札)
us : 捨札数

--------------------------------------------------------------------*/

int strategy(const int hd[], const int fd[], int cg, int tk, const int ud[], int us) {
  int sut[4] = {0};  // スート
  int num[13] = {0}; // 数位
  int usut[4] = {0}; // 捨て札のスート
  int unum[13] = {0}; // 捨て札の数位
  int i,j;
  int a = 1000; // 答えの格納

  // 倍率が低い時、役ができていたら終了する
  if ( poker_point(hd) > 0 && tk <= 2 ) {
    return -1;
  } else if ( tk <= 1 && cg >= 2 ) {
    return -1;
  }

  // スートの数を数える
  for ( i = 0; i < HNUM; i++ ) {
    sut[(hd[i] / 13)]++;
  }

  // 捨て札のスートの数を数える
  for ( i = 0; i < us; i++ ) {
    usut[(ud[i] / 13)]++;
  }

  // 数位を記録する
  for ( i = 0; i < HNUM; i++ ) {
    num[(hd[i] % 13)]++;
  }

  // 捨て札の数位を記録する
  for ( i = 0; i < us; i++ ) {
    unum[(ud[i] % 13)]++;
  }

  // 4カード判定
  for ( i = 0; i < 13; i++ ) {
    if ( num[i] >= 4 ) {
      return -1;
    }
  }

  // 3つ以上連番があればストレートを狙う
  a = staright_h(hd,num);
  if ( a != 1000 ) {
    return a;
  }

 // ツーペアもしくはスリーカードの場合フルハウス狙い
  a = fullhouse_h(num,hd);
  if ( a != 1000 ) {
    return a;
  }

  // 同じスートが3以上の時にフラッシュを狙う
  a = flash_h(sut,hd,usut);
  if ( a != 1000 ) {
    return a;
  }

  //  ワンペアの時、ツーペアorスリーカインズ狙い
  a = pair_h(num,hd,unum);
  if ( a != 1000 ) {
    return a;
  }

  if ( poker_point(hd) > 1 ) {
    return -1;
  } else {
    return 0;
  }
}


//====================================================================
//  補助関数
//====================================================================

//====================================================================
//  連番3つでストレート狙い
//====================================================================

int staright_h(const int hd[], const int num[]) {
  int i,j,i2;
  int len = 0;
  int lmin;

  for ( i = 0; i < 13; i++ ) {
    if ( num[i] > 0 ) {
      len++; 
      if ( len == 5 ) {
        return -1;
      }
    } else if ( len >= 3 ) {
      for ( i2 = 0; i2 < 13; i2++ ) {
        if ( num[i2] > 1 ) {
          for ( j = 0; j < HNUM; j++ ) {
            if ( (hd[j] % 13) == i2 ) {
              return j;
            }
          }
        }
      }
      lmin = i - (len - 1);
      for ( i2 = i; i2 < 13; i2++ ) {
        if ( num[i2] > 0 && (i2 < lmin || i2 > lmin + (len - 1)) ) {
          for ( j = 0; j < HNUM; j++ ) {
            if ( (hd[j] % 13) == i2 ) {
              return j;
            }
          }
        }
        if ( i2 == 12 ) {
          i2 = -1;
        }
      }
    } else {
      len = 0;
    }
  }
  return 1000;
}

//====================================================================
//  同じスート3つでフラッシュ狙い
//====================================================================

int flash_h(const int sut[], const int hd[], int usut[]) {
  int i,j;

  for ( i = 0; i < 5; i++ ) {
    if ( sut[i] >= 3 && usut[i] < 9 ) {
      if ( sut[i] == 5 ) {
        return -1;
      }
      for ( j = 0; j < HNUM; j++ ) {
        if ( (hd[j] / 13) != i ) {
          return j;
        }
      }
    }
  }
  return 1000;
}

//====================================================================
//  ツーペアorスリーカインズでフルハウス狙い
//====================================================================

int fullhouse_h(const int num[], const int hd[]) {
  int i,j;
  int p[2] = {0};
  int c2 = 0, c3 = 0;

  for ( i = 0; i < 13; i++ ) {
    if ( num[i] >= 3 ) {
      c3++;
    } else if ( num[i] >= 2 ) {
      c2++;
      if ( p[0] == 0 ) {
        p[0] = i;
      } else {
        p[1] = i;
      }
    }
  }
  if ( c3 == 1 && c2 == 1 ) {
    return -1;
  } else if ( c3 == 1 && c2 == 0 ) {
    for ( i = 0; i < 13; i++ ) {
      if ( num[i] == 1 ) {
        for ( j = 0; j < HNUM; j++ ) {
          if ( (hd[j] % 13) == i ) {
            return j;
          }
        }
      }
    }
  } else if ( c2 == 2 ) {
    for ( i = 0; i < 13; i++ ) {
      if ( num[i] == 1 ) {
        for ( j = 0; j < HNUM; j++ ) {
          if ( (hd[j] % 13) == i ) {
            return j;
          }
        }
      }
    }
  }
  return 1000;
}

//====================================================================
//  ワンペアの時、ツーペアorスリーカインズ狙い
//====================================================================

int pair_h(const int num[], const int hd[], int unum[]){
  int i,j;
  int p[3] = {0};
  int umin;

  for ( i = 0; i < 13; i++ ) {
    if ( num[i] == 2 ) {
      for ( i = 0; i < 13; i++ ) {
        if ( num[i] == 1 ) {
          if ( p[0] == 0 ) {
            p[0] = i;
          } else if ( p[1] == 0 ) {
            p[1] = i;
          } else{
            p[2] = i;
          }
          umin = unum[p[0]];
          // 捨て数が最小の数位を格納
          for ( j = 1; j < 3; j++ ) {
            if ( umin > unum[p[j]] ) {
              umin = unum[p[j]];
              p[0] = p[j]; // p[0]に捨て数が最小の数位を格納
            }
          }
          for ( j = 0; j < HNUM; j++ ) {
            if ( (hd[j] % 13) != p[0] ) {
              return j;
            }
          }
        }
      }
    }
  }
  return 1000;
}
