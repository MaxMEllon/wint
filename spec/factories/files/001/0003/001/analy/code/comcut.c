int staright_h(const int hd[], const int num[]);
int flash_h(const int sut[], const int hd[], int usut[]);
int fullhouse_h(const int num[], const int hd[]);
int pair_h(const int num[], const int hd[], int unum[]);
int strategy(const int hd[], const int fd[], int cg, int tk, const int ud[], int us) {
  int sut[4] = {0};
  int num[13] = {0};
  int usut[4] = {0};
  int unum[13] = {0};
  int i,j;
  int a = 1000;
  if ( poker_point(hd) > 0 && tk <= 2 ) {
    return -1;
  } else if ( tk <= 1 && cg >= 2 ) {
    return -1;
  }
  for ( i = 0; i < HNUM; i++ ) {
    sut[(hd[i] / 13)]++;
  }
  for ( i = 0; i < us; i++ ) {
    usut[(ud[i] / 13)]++;
  }
  for ( i = 0; i < HNUM; i++ ) {
    num[(hd[i] % 13)]++;
  }
  for ( i = 0; i < us; i++ ) {
    unum[(ud[i] % 13)]++;
  }
  for ( i = 0; i < 13; i++ ) {
    if ( num[i] >= 4 ) {
      return -1;
    }
  }
  a = staright_h(hd,num);
  if ( a != 1000 ) {
    return a;
  }
  a = fullhouse_h(num,hd);
  if ( a != 1000 ) {
    return a;
  }
  a = flash_h(sut,hd,usut);
  if ( a != 1000 ) {
    return a;
  }
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
          for ( j = 1; j < 3; j++ ) {
            if ( umin > unum[p[j]] ) {
              umin = unum[p[j]];
              p[0] = p[j];
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