int flashreach(int hd[], int sut[], int usut[]);
int straight(int hd[], int num[], int unum[], int sut[], int usut[]);
int flash(int hd[], int num[], int unum[], int sut[], int usut[]);
int pair(int hd[], int num[], int unum[], int sut[]);
int waste_1pair(int hd[], int pair, int unum[], int sut[]);
int take6_hand(int hd[], int ud[], int us);
int strategy(const int hd[], const int fd[], int cg, int tk, const int ud[], int us) {
  int i, k, decide;
  int sut[4] = {0};
  int num[13] = {0};
  int usut[4] = {0};
  int unum[13] = {0};
  for ( k = 0; k < HNUM; k++ ) { i = hd[k] / 13; sut[i]++; }
  for ( k = 0; k < HNUM; k++ ) { i = hd[k] % 13; num[i]++; }
  for ( k = 0; k < us; k++ ) { i = ud[k] / 13; usut[i]++; }
  for ( k = 0; k < us; k++ ) { i = ud[k] % 13; unum[i]++; }
  if (tk == 5 && us-cg >= 37) { return take6_hand(hd, ud, us); }
  if (poker_point(hd) >= 16) { return -1; }
  if (poker_point(hd) >= 8 && tk < 4) { return -1; }
  decide = flashreach(hd, sut, usut);
  if (decide != -1) {
    return decide;
  }
  decide = straight(hd, num, unum, sut, usut);
  if (decide != -1) {
    return decide;
  }
  if (tk < 2) { return -1; }
  decide = flash(hd, num, unum, sut, usut);
  if (decide != -1) {
    return decide;
  }
  if (tk == 4 && 52-5-us <= 11) {
    return -1;
  }
  if (tk == 3 && 52-5-us <= 22) {
    return -1;
  }
  decide = pair(hd, num, unum,sut);
  if (decide != -1) {
    return decide;
  }
  return -1;
}
int straight(int hd[], int num[], int unum[], int sut[], int usut[]) {
  int i, j, k; int findflag = 0;
  int len = 0; int maxlen = 0; int lastcard;
  int hitcard1 = -1; int hitcard2 = -1;
  int waste[2]; int wastenum[2];
  int keepcards[4];
  for ( k = 0; k < 14; k++ ) {
    if ( num[k%13] > 0 ) {
      len++;
      if ( len == 5 ) { break; }
    } else {
      if (maxlen < len) { maxlen = len; lastcard = k-1; }
      len = 0;
      if (maxlen >= 3) { break; }
    }
  }
  if (maxlen < len) { maxlen = len; lastcard = (k-1)%13; }
  if (maxlen == 5) {
    return -1;
  } else if (maxlen == 4) {
    hitcard1 = lastcard-4; hitcard2 = lastcard+1;
    if (hitcard2 == 1) { hitcard2 = -1; }
    for (i=0; i<4; i++) {
      keepcards[i] = (lastcard-i)%13;
    }
  } else if (maxlen == 3) {
    if (lastcard <= 11 && num[lastcard+2] >= 1) {
      hitcard1 = lastcard+1;
      for (i=0; i<3; i++) {
        keepcards[i] = (lastcard-i)%13;
      }
      keepcards[3] = (lastcard+2)%13;
    } else if (lastcard >= 2 && num[lastcard-4] >= 1) {
      hitcard1 = lastcard-3;
      for (i=0; i<3; i++) {
        keepcards[i] = (lastcard-i)%13;
      }
      keepcards[3] = (lastcard-4)%13;
    } else {
      return -1;
    }
  } else if (maxlen == 2) {
    if (lastcard <= 10 && num[lastcard+2] >= 1 && num[(lastcard+3)%13] >= 1) {
      hitcard1 = lastcard+1;
      for (i=0; i<2; i++) {
        keepcards[i*2] = (hitcard1-i-1)%13;
        keepcards[i*2+1] = (hitcard1+i+1)%13;
      }
    } else if (lastcard >= 5 && num[lastcard-4] >= 1 && num[lastcard-3] >= 1) {
      hitcard1 = lastcard-2;
      for (i=0; i<2; i++) {
        keepcards[i*2] = (hitcard1-i-1)%13;
        keepcards[i*2+1] = (hitcard1+i+1)%13;
      }
    } else {
      return -1;
    }
  } else {
    return -1;
  }
  if (hitcard1 >= 0) {
    if ( num[hitcard1] + unum[hitcard1] >= 13) { findflag++; }
  }
  if (hitcard2 >= 0) {
    if ( num[hitcard2] + unum[hitcard2] >= 13) { findflag += 2; }
  }
  if (findflag == 3) {
    return -1;
  } else if (hitcard2 >= 0 && findflag == 2) {
    return -1;
  } else if (hitcard1 >= 0 && findflag == 1) {
    return -1;
  }
  j = 0;
  for (k=0; k<HNUM; k++) {
    if (num[hd[k]%13] >= 2) {
      wastenum[j] = sut[k/13] + usut[k/13]; waste[j] = k;
      if (j == 2) { break; }
    }
    findflag = 0;
    for (i=0; i<4; i++) {
      if (hd[k]%13 == keepcards[i]) {
        findflag++;
      }
    }
    if (findflag == 0) { return k; }
  }
  if (wastenum[0] < wastenum[1]) { return waste[1]; } else { return waste[0]; }
  return -1;
}
int flash(int hd[], int num[], int unum[], int sut[], int usut[]) {
  int i, j, k;
  int ucount[2] = {0}; int ucard[2] = {0}; int waste;
  j = 0;
  for ( k = 0; k < 4; k++ ) {
    if ( sut[k] >= 3 ) {
      if ( sut[k] + usut[k] >= 13) { return -1; }
      for ( i = 0; i < HNUM; i++) {
        if ( hd[i] / 13 != k ) {
          ucount[j] = num[hd[i]%13] + unum[hd[i]%13]; ucard[j] = i; j++;
          if ( j == 2 ) { break; }
        }
      }
      if ( ucount[0] < ucount[1] ) { return ucard[1]; } else { return ucard[0]; }
    }
  }
  return -1;
}
int flashreach(int hd[], int sut[], int usut[]) {
  int i, k;
  for ( k = 0; k < 4; k++ ) {
    if ( sut[k] >= 4 ) {
      if ( sut[k] + usut[k] >= 13) { return -1; }
      for (i=0; i<HNUM; i++) {
        if ( hd[i] / 13 != k ) {
          return i;
        }
      }
    }
  }
  return -1;
}
int pair(int hd[], int num[], int unum[], int sut[]) {
  int i, j, k;
  int c2 = 0; int c3 = 0; int c4 = 0;
  int pairs[2] = {0};
  int ucount[2] = {0}; int ucard[2] = {0}; int waste;
  j = 0;
  for ( k = 0; k < 13; k++ ) {
    if ( num[k] == 4 ) { c4++; break; }
    if ( num[k] == 3 ) { c3++; break; }
    if ( num[k] == 2 ) { c2++; pairs[j] = k; j++; }
  }
  if (c4 == 1) { return -1; }
  if (c3 == 1) {
    i = k;
    for ( k = 0; k < 13; k++ ) {
      if ( num[k] == 1 ) { ucount[j] = 1+unum[k]; ucard[j] = k; j++; }
      if ( j == 2 ) { break; }
    }
    if ( ucount[0] < ucount[1] ) { waste = ucard[1]; } else { waste = ucard[0]; }
    for ( k = 0; k < HNUM; k++ ) {
      if ( waste == hd[k] ) {
        if ( unum[i] >= 1) { return -1; } else { return k; }
      }
    }
  }
  if (c2 == 2) {
    for (i=0; i<HNUM; i++) {
      if ( hd[i] % 13 != pairs[0] && hd[i] % 13 != pairs[1]) {
        if (num[pairs[0]] + unum[pairs[0]] == 4 && num[pairs[1]] + unum[pairs[1]] == 4) {
          return -1;
        } else {
          return i;
        }
      }
    }
  } else {
    return waste_1pair(hd, pairs[0], unum, sut);
  }
  return -1;
}
int waste_1pair(int hd[], int pair, int unum[], int sut[]) {
  int i; int min = 0; int waste;
  if (unum[pair] >= 2) {
    for (i = 0; i < HNUM; i++) {
      if (sut[hd[i]/13] == 1) { return i; }
    }
    return -1;
  }
  for (i = 0; i < HNUM; i++) {
    if (hd[i] % 13 == pair) { continue; }
    if (unum[hd[i]%13] + 1 > min) {
      waste = i; min = unum[hd[i]%13] + 1;
    }
  }
  return waste;
}
int take6_hand(int hd[], int ud[], int us) {
  int i, j, k, a, b, c, d, find_flag, point; int maxpoint = 0;
  int remain_cards[25] = {-1};
  int hand_a[5]; int hand_remain[5];
  k = 0;
  for (i=0; i<51; i++) {
    find_flag = 0;
    for (j=0; j<us; j++) {
      if (ud[j] == i) { find_flag = 1; break; }
    }
    if (find_flag == 0) {
      remain_cards[k] = i; k++;
    }
  }
  for (i=0; i<k-4; i++) {
    for (j=i+1; j<k-3; j++) {
      for (a=j+1; a<k-2; a++) {
        for (b=a+1; b<k-1; b++) {
          for (c=b+1; c<k; c++) {
            hand_a[0] = remain_cards[i];
            hand_a[1] = remain_cards[j];
            hand_a[2] = remain_cards[a];
            hand_a[3] = remain_cards[b];
            hand_a[4] = remain_cards[c];
            point = poker_point(hand_a);
            if (point > maxpoint) {
              for (d=0; d<5; d++) {
                hand_remain[d] = hand_a[d];
              }
              maxpoint = point;
            }
          }
        }
      }
    }
  }
  if (maxpoint <= poker_point(hd)) { return -1; }
  for (i=0; i<HNUM; i++) {
    find_flag = 0;
    for (j=0; j<5; j++) {
      if (hd[i] == hand_remain[j]) { find_flag = 1; break; }
    }
    if (find_flag == 0) { return i; }
  }
  return -1;
}