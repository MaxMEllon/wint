int Four_of_a_kind( const int hd[], int cg, int us );
int Straight( const int hd[], int cg, int us );
int Full_house( const int hd[], int cg, int us );
int Flush( const int hd[], int cg, int us );
int Three_of_a_kind( const int hd[], int cg, int us );
int Two_pair( const int hd[], int cg, int us );
int One_pair( const int hd[], int cg, int us );
int Final( const int hd[], int cg, int us );
int Combi( int a, int b );
int Permu( int a, int b );
int Reach_check( void );
void Separate_hand( const int hd[] );
void Separate_dishand( const int ud[], int us );
void Check_len( void );
void Init_flg( void );
  struct card{
    int orig;
    int mark;
    int num;
  };
  struct card hand[6] = {0};
  struct card dishand[52] = {0};
  int sut[4] ={0};
  int Num[14] ={0};
  int udsut[4] ={0};
  int udNum[13]={0};
  int flg[15] ={0};
  int count = 0;
  int deck_flg[52] = {0};
  int ch = 0;
int strategy( const int hd[], const int fd[], int cg, int tk, const int ud[], int us) {
  int i ;
  int ret = -1;
  Separate_hand( hd );
  Separate_dishand( ud, us );
  for( i=0; i<52; i++){ deck_flg[i] = 0; }
  for( i=0; i<us; i++){ deck_flg[ud[i]] = 1; }
  for( i=0; i<HNUM; i++ ){ deck_flg[hd[i]] = 1; }
  ch = Reach_check();
  if( tk < 2 ){
    if( ch == 1 ){
      return Flush(hd,cg,us);
    }else if( ch == 2 ){
      return Flush(hd,cg,us);
    }else{
      return -1;
    }
  }
  if( tk == 3 && 52-HNUM-us <= 22) { return -1; }
  if( tk == 5 ){ ret = Final(hd,cg,us); }
  if( ret == -1 ){ ret = Flush(hd,cg,us); }
  return ret;
}
int Four_of_a_kind( const int hd[], int cg, int us ){
  int i, j;
  int num_min;
  int target;
  struct card deck[13] = {0};
  int ret = -1;
  int ret2 = -1;
  int tmp1 = -1, tmp2 = -1;
  if( poker_point(hd) > P7 ){ return -1; }
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }
  for( i=0; i<13; i++ ){
    if( Num[i] == 3 ){
      target = i;
    }
  }
  if( deck[target].num < 1 ){ return Full_house(hd,cg,us); }
  for( i=0; i<13; i++ ){
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
    if( deck[tmp1].num < deck[tmp2].num ){
      ret =tmp1;
    }else if( deck[tmp2].num < deck[tmp2].num ){
      ret = tmp2;
    }else if( deck[tmp1].num == deck[tmp2].num ){
      if( deck[hand[tmp1].mark].mark < deck[hand[tmp2].mark].mark ){
        ret = tmp1;
      }else{
        ret = tmp2;
      }
    }
    for( i=0; i<HNUM; i++ ){
      if( hand[i].num == ret ){ return i; }
    }
  }else {
    for( i=0; i<HNUM; i++ ){
      if( hand[i].num =! target ){
        for( j=i+1; j<HNUM; j++ ){
          if( hand[i].num != target ){
            if( deck[hand[i].mark].mark < deck[hand[j].mark].mark ){
              return i;
            }else{
              return j;
            }
          }
        }
      }
    }
  }
  return ret2;
}
int Straight( const int hd[], int cg, int us ){
  int i, j,k;
  int a,b,c;
  int chng=-1;
  int ret = -1;
  struct card deck[14] = {0};
  double deck_pro[14] = {0};
  double hand_pro[13] = {0};
  double min =100;
  int count = 0;
  int tmp1, tmp2;
  if( poker_point(hd) >= P4 ){ return -1; }
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }
  deck[13].num = deck[0].num;
  for( i=0; i<4; i++ ){
    if( 1 < Num[i] ){
      for( j=0; j<HNUM; j++){
        if( hand[j].num == i ){ tmp1 = j; break;}
      }
      for( k=0; k<HNUM; k++){
        if( hand[k].num == i && tmp1 != k ){ tmp2 = k; }
      }
      if( deck[tmp1].num < deck[tmp2].num ){
        return tmp1;
      }else{
        return tmp2;
      }
    }
  }
  for( i=0; i<HNUM; i++ ){
    for( j=0; j<14; j++ ){
      if( hand[i].num != j && flg[j] != -1 ){
        flg[j] = deck[j].num;
      }else{
        flg[j] = -1;
      }
    }
  }
  flg[13] = flg[0];
  for( i=0; i<14-4; i++ ){
    a = 1;
    count = 0;
    for( j=i; j<i+HNUM; j++ ){
      if( flg[j] != -1 && flg[j] != 0 ){
        a *= flg[j];
        count++;
      }
    }
    b = Permu( (52-HNUM-us)-count, count);
    c = Permu( 52-HNUM-us, CHNG-cg );
    for( k=i; k<i+HNUM; k++ ){
      deck_pro[k] += (double)(a*b)/c;
    }
  }
  deck_pro[0] += deck_pro[13];
  for( i=0; i<13; i++ ){
    for( j=0; j<HNUM; j++ ){
      if( i == hand[j].num ){
        hand_pro[i] = deck_pro[i];
      }
    }
  }
  for( i=0; i<13; i++ ){
    if( hand_pro[i] < min && hand_pro[i] != 0 ){
      min = hand_pro[i];
      chng = i;
    }
  }
  for( i=0; i<HNUM; i++ ){
    if( hand[i].num == chng ){
      ret = i;
    }
  }
  return ret;
}
int Flush( const int hd[], int cg, int us ){
  int target;
  struct card deck[13] = {0};
  double Mark[4] = {0};
  double hand_pro[5] = {0};
  double min = 1;
  int chng_mark = 0;
  int sut_max = 0;
  int ret=0;
  int i, j;
  int a, b;
  if( poker_point(hd) >= P5 ){ return -1; }
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<HNUM; i++ ){
    if( CHNG-cg < HNUM-sut[i] || deck[hand[i].mark].mark == 0 ){
      hand_pro[i] = 0;
    }else{
      a = Combi( deck[hand[i].mark].mark, HNUM - sut[hand[i].mark] );
      b = Combi( (52-us-HNUM), HNUM - sut[hand[i].mark] );
      hand_pro[i] = (double)a/b;
    }
  }
  for( i=0; i<4; i++ ){
    if( sut_max < sut[i] ){
      sut_max = sut[i];
      target = i;
    }
  }
  if( sut[target] == 2 || sut[target] == 3 || sut[target] == 4 ){
    for( j=0; j<HNUM; j++ ){
      if( hand[j].mark == target ){
        hand_pro[j] = 1.0;
      }
    }
  }
  for( i=0; i<HNUM; i++ ){
    if( hand_pro[i] < min ){ min = hand_pro[i]; chng_mark = i; }
  }
  ret = chng_mark;
  return ret;
}
int Full_house( const int hd[], int cg, int us ){
  int i, j, k;
  int a, b;
  int ret = -1;
  double hand_pro[5] = {0};
  double min = 1;
  int chng_num = 0;
  struct card deck[13] = {0};
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }
  if( poker_point(hd) > P6 ){ return -1; }
  if( poker_point(hd) == P0){ One_pair(hd,cg,us); }
  if( poker_point(hd) == P1){ Two_pair(hd,cg,us); }
  for( i=0; i<13; i++ ){
    if( Num[i] == 3 ){
      for( k=0; k<HNUM; k++ ){
        if( hand[k].num != i ){
          hand_pro[k] = (double)deck[hand[k].num].num/(52-us-HNUM);
        }else{
          hand_pro[k] = 1.0;
        }
      }
      for( i=0; i<HNUM; i++ ){
        if( hand_pro[i] < min ){ min = hand_pro[i]; chng_num = i; }
      }
      ret = chng_num;
      return ret;
    }
  }
  for( i=0; i<13; i++ ){
    if( Num[i] == 2 ){
      for( j=i+1; j<13; j++ ){
        if( Num[j] == 2 ){
          for( k=0; k<HNUM; k++ ){
            if( hand[k].num != i && hand[k].num != j ){
              return k;
            }
          }
        }
      }
    }
  }
  return -1;
}
int Three_of_a_kind( const int hd[], int cg, int us ){
  int i, j;
  if( poker_point(hd) > P3 ){ return -1; }
  for( i=0; i<13; i++ ){
    if( Num[i] == 2 ){ break; }
  }
  for( j=0; j<5; j++ ){
    if( hand[j].num == i ){ return j; }
  }
  return -1;
}
int Two_pair( const int hd[], int cg, int us ){
  int i, j, k;
  int ret = -1;
  double hand_pro[5] = {0};
  double min = 1;
  int chng_num = 0;
  struct card deck[13] = {0};
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }
  if( poker_point(hd) > P2 ){ return -1; }
  for( i=0; i<13; i++ ){
    if( Num[i] == 2 ){
      for( k=0; k<5; k++ ){
        if( hand[k].num != i ){
          hand_pro[k] = (double)deck[hand[k].num].num/(52-us-HNUM);
        }else{
          hand_pro[k] = 1.0;
        }
      }
      for( i=0; i<HNUM; i++ ){
        if( hand_pro[i] < min ){ min = hand_pro[i]; chng_num = i; }
      }
      ret = chng_num;
      return ret;
    }
  }
  return -1;
}
int One_pair( const int hd[], int cg, int us ){
  int i, j, k, m, s, t;
  int a,b;
  int ret;
  double hand_pro[5] = {0};
  double min = 1;
  int chng_num = 0;
  struct card deck[14] = {0};
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }
  for( i=0; i<HNUM; i++ ){ hand_pro[i] = (double)deck[hand[i].num].num/(52-us-HNUM); }
  for( i=0; i<HNUM; i++ ){
    if( hand_pro[i] < min ){ min = hand_pro[i]; chng_num = i; }
  }
  ret = chng_num;
  return ret;
}
int Final( const int hd[], int cg, int us ){
  struct card deck[13] = {0};
  int i, j, k, l, m, n;
  int flag[5] = {0};
  int max_point = 0;
  struct card mer_deck[13] = {0};
  struct card ideal_hand[5]= {0};
  int vir_hand[5] = {0};
  int vir_deck[52] = {0};
  int deck_max = 0;
  for( i=0; i< 4; i++ ){ deck[i].mark = 13-(sut[i] + udsut[i]); }
  for( i=0; i<13; i++ ){ deck[i].num = 4-(Num[i] + udNum[i]); }
  for( i=0; i< 4; i++ ){ mer_deck[i].mark = deck[i].mark + sut[i] ; }
  for( i=0; i<13; i++ ){ mer_deck[i].num = deck[i].num + Num[i] ; }
  for( j=0, i=0; i<52; i++ ){
    if( deck_flg[i] == 0 ){
      vir_deck[j] = i;
      j++;
    }
  }
  for( i=0; i<HNUM; i++ ){
      vir_deck[j] = hand[i].orig;
      j++;
  }
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
              ideal_hand[0].orig = vir_hand[0];
              ideal_hand[1].orig = vir_hand[1];
              ideal_hand[2].orig = vir_hand[2];
              ideal_hand[3].orig = vir_hand[3];
              ideal_hand[4].orig = vir_hand[4];
            }
          }
        }
      }
    }
  }
  for( i=0; i<HNUM; i++ ){
    ideal_hand[i].mark = ideal_hand[i].orig/13;
    ideal_hand[i].num = ideal_hand[i].orig%13;
  }
  for( i=0; i<HNUM; i++ ){
    for( j=0; j<HNUM; j++ ){
      if( hand[i].orig == ideal_hand[j].orig ){
        flag[i] = 1;
      }
    }
  }
  for( i=0; i<HNUM; i++ ){
    if( flag[i] == 0 ){ return i; }
  }
  return -1;
}
void Separate_hand( const int hd[] ){
  int i;
  for( i=0; i< 4; i++){ sut[i] = 0; }
  for( i=0; i<13; i++){ Num[i] = 0; }
  for( i=0; i<5; i++ ){
    hand[i].orig = hd[i];
    hand[i].mark = hd[i]/13;
    hand[i].num = hd[i]%13;
    sut[hand[i].mark]++;
    Num[hand[i].num]++;
  }
}
void Separate_dishand( const int ud[], int us ){
  int i;
  for( i=0; i< 4; i++){ udsut[i] = 0; }
  for( i=0; i<13; i++){ udNum[i] = 0; }
  for( i=0; i<us; i++ ){
    dishand[i].orig = ud[i];
    dishand[i].mark = ud[i]/13;
    dishand[i].num = ud[i]%13;
    udsut[dishand[i].mark]++;
    udNum[dishand[i].num]++;
  }
}
void Check_len( void ){
  int i;
  count = 0;
  Init_flg();
  for( i=1; i<=13; i++ ){
    if( i == 13 ){
      if( Num[0] != 0 ){
        count++;
      }else{
        count = 0;
      }
    }else if( Num[i] != 0 ){
      count++;
    }else{
      count = 0;
    }
    flg[i] = count;
  }
  if( flg[13] != 0 && flg[1] != 0 ){ flg[0] = flg[13]; flg[1] = flg[13]+1; }
}
int Combi( int a, int b ){
  int i;
  int tmp = 1;
  for( i=a; a-b<i; i-- ){ tmp *= i; }
  for( i=b; 0<i; i-- ){ tmp /= i; }
  if( tmp == 0 ){ tmp = 1; }
  return tmp;
}
int Permu( int a, int b ){
  int i;
  int tmp = 1;
  for( i=a; a-b<i; i-- ){ tmp *= i; }
  if( a < 0 || b < 0 || tmp == 0 ){ tmp = 1; }
  return tmp;
}
int Reach_check( void ){
  struct card vir_hand[5] = {0};
  struct card vir_deck[52] = {0};
  int deck_max;
  int i,j,k;
  int virNum[13] = {0};
  for( j=0, i=0; i<52; i++ ){
    if( deck_flg[i] == 0 ){
      vir_deck[j].orig = i;
      j++;
    }
  }
  for( i=0; i<HNUM; i++ ){
      vir_deck[j].orig = hand[i].orig;
      j++;
  }
  deck_max = j;
  for( i=0; i<deck_max; i++ ){
    vir_deck[i].mark = vir_deck[i].orig / 13;
    vir_deck[i].num = vir_deck[i].orig % 13;
  }
  for( i=0; i<deck_max-5; i++ ){ virNum[vir_deck[i].num]++; }
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
  for( i=0; i<4; i++ ){
    if( 3 < sut[i] ){ return 2; }
  }
  return -1;
}
void Init_flg( void ){
  int i;
  for( i=0; i<15; i++ ){ flg[i] = 0;}
}