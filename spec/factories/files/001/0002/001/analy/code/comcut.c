typedef struct handcard {
  int num_val;
  int num;
  int sut;
  int pos;
  double exp[11];
} Handcard;
typedef struct cards {
  int amount;
  int sut[4];
  int num[13];
  int card[4][13];
} Cards;
int flush(Handcard hd[], Cards hand_card, Cards deck_card, int cg);
int pair(Handcard hd[], Cards hand_card, Cards deck_card, Cards remain_card);
int straight(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg);
int full_house(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg);
int four_of_a_kind(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg);
int straight_flush(Handcard hd[], Cards hand_card, Cards deck_card, int cg);
int royal_straight_flush(Handcard hd[], Cards remain_card, Cards deck_card, int cg);
int final_attack(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg);
int check_straight(Cards remain_card, Cards hand_card);
double combination(int n, int m);
double permutation(int n, int m);
void calc_card(Handcard hand[], Cards *remain_card, Cards *deck_card, Cards *hand_card, const int ud[], int us);
void bubble_sort_role(Handcard hd[], int n, int role);
int limit_take(int cg, int tk, Handcard hands[], Cards remain_card, Cards hand_card, Cards deck_card, int hd[]);
int decide_discard(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg, int tk);
void sum_exps(Handcard hd[], int tk);
int strategy(const int hd[], const int fd[], int cg, int tk, const int ud[], int us)
{
  int disc_num;
  int t;
  int k, k1, k2;
  Handcard hands[5];
  Cards hand_card, deck_card, remain_card;
  for (k1 = 0; k1 < HNUM; k1++ ) {
    hands[k1].num_val = hd[k1];
    hands[k1].num = hd[k1] % 13;
    hands[k1].sut = hd[k1] / 13;
    hands[k1].pos = k1;
    for ( k2 = 0; k2 < 11; k2++ ) { hands[k1].exp[k2] = 0; }
  }
  calc_card(hands, &remain_card, &deck_card, &hand_card, ud, us);
  if ( tk != 5 && poker_point(hd) >= P6 ) { return -1; }
  disc_num = limit_take(cg, tk, hands, remain_card, hand_card, deck_card, hd); if ( disc_num != 10 ) { return disc_num; }
  if ( check_straight(remain_card, hand_card) >= 1 ) {
    return straight(hands, remain_card, hand_card, deck_card, cg);
  }
  for (k1 = 0; k1 < HNUM; k1++ ) {
    if ( hand_card.sut[k1] >= 4 && deck_card.sut[k1] >= 2 ) {
      return flush(hands, hand_card, deck_card, cg);
    }
  }
  if ( poker_point_pair(hand_card.num) == P3 ) {
    return pair(hands, hand_card, deck_card, remain_card);
  }
  return decide_discard(hands, remain_card, hand_card, deck_card, cg, tk);
}
void calc_card(Handcard hand[], Cards *remain_card, Cards *deck_card, Cards *hand_card, const int ud[], int us)
{
  int k1, k2, card_num = 0;
  for ( k1 = 0; k1 < 13; k1++ ) { hand_card->num[k1] = 0; }
  for ( k1 = 0; k1 < 4; k1++ ) { hand_card->sut[k1] = 0; }
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 13; k2++ ) { hand_card->card[k1][k2] = 0; }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hand_card->num[hand[k1].num]++;
    hand_card->sut[hand[k1].sut]++;
    hand_card->card[hand[k1].sut][hand[k1].num]++;
  }
  hand_card->amount = HNUM;
  for ( k1 = 0; k1 < 13; k1++ ) { remain_card->num[k1] = 4; }
  for ( k1 = 0; k1 < 4; k1++ ) { remain_card->sut[k1] = 13; }
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 13; k2++ ) {
      remain_card->card[k1][k2] = 1;
      card_num++;
    }
  }
  for ( k1 = 0; k1 < us; k1++ ) {
    remain_card->num[ud[k1] % 13]--;
    remain_card->sut[ud[k1] / 13]--;
    remain_card->card[ud[k1] / 13][ud[k1] % 13]--;
    card_num--;
  }
  remain_card->amount = card_num;
  for ( k1 = 0; k1 < 13; k1++ ) { deck_card->num[k1] = 0; }
  for ( k1 = 0; k1 < 4; k1++ ) { deck_card->sut[k1] = 0; }
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 13; k2++ ) { deck_card->card[k1][k2] = 0; }
  }
  deck_card->amount = 52 - us - HNUM;
  for ( k1 = 0; k1 < 4; k1++ ) {
    deck_card->sut[k1] = remain_card->sut[k1] - hand_card->sut[k1];
  }
  for ( k1 = 0; k1 < 13; k1++ ) {
    deck_card->num[k1] = remain_card->num[k1] - hand_card->num[k1];
  }
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 13; k2++ ) {
      deck_card->card[k1][k2] = remain_card->card[k1][k2] - hand_card->card[k1][k2];
    }
  }
}
int limit_take(int cg, int tk, Handcard hands[], Cards remain_card, Cards hand_card, Cards deck_card, int hd[])
{
  int t;
  int k;
  int flag = 0;
  if ( tk == 0 ) {
    if ( check_straight(remain_card, hand_card) >= 1 ) { flag = 1; }
    for ( k = 0; k < 4; k++ ) { if ( hand_card.sut[k] >= 4 ) { flag = 1; } }
    if ( poker_point(hd) >= P3 ) { flag = 1; }
    if ( flag == 0 ) { return -1; }
  }
  if ( tk == 1 ) {
    for ( k = 0; k < 4; k++ ) { if ( hand_card.sut[k] >= 4 ) { flag = 1; } }
    if ( check_straight(remain_card, hand_card) >= 3 ) { flag = 1; }
    if ( poker_point(hd) >= P3 ) { flag = 1; }
    if ( flag == 0 ) { return -1; }
  }
  if ( tk == 4 && deck_card.amount <= 11 ) { return -1; }
  if ( tk == 3 && deck_card.amount <= 22 ) { return -1; }
  if ( tk < 3 && cg >= 4 ) {
    for ( k = 0; k < 4; k++ ) {
      if ( hand_card.sut[k] >= 4 ) {
        return flush(hands, hand_card, deck_card, cg);
      }
    }
    if ( check_straight(remain_card, hand_card) >= 1 ) {
      return straight(hands, remain_card, hand_card, deck_card, cg);
    }
    if ( poker_point(hd) >= P3 ) {
      return pair(hands, hand_card, deck_card, remain_card);
    }
    return -1;
  }
  if ( tk == 5 ) { return final_attack(hands, remain_card, hand_card, deck_card, cg); }
  return 10;
}
int decide_discard(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg, int tk)
{
  four_of_a_kind(hd, remain_card, hand_card, deck_card, cg);
  flush(hd, hand_card, deck_card, cg);
  straight(hd, remain_card, hand_card, deck_card, cg);
  full_house(hd, remain_card, hand_card, deck_card, cg);
  sum_exps(hd, tk);
  bubble_sort_role(hd, HNUM, 10);
  return hd[0].pos;
}
int final_attack(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg)
{
  int k1;
  int len = 0;
  int flag;
  int disc_num;
  int hand[HNUM];
  for ( k1 = 0; k1 < HNUM; k1++ ) { hand[k1] = hd[k1].num_val; }
  if ( poker_point(hand) >= P9 ) { return -1; }
  disc_num = royal_straight_flush(hd, remain_card, deck_card, cg);
  if ( disc_num != -1 ) { return disc_num; }
  if ( poker_point(hand) >= P8 ) { return -1; }
  disc_num = straight_flush(hd, hand_card, deck_card, cg);
  if ( disc_num != -1 ) { return disc_num; }
  if ( poker_point(hand) >= P7 ) { return -1; }
  disc_num = four_of_a_kind(hd, remain_card, hand_card, deck_card, cg);
  if ( disc_num != -1 ) { return disc_num; }
  flag = 0;
  if ( poker_point(hand) >= P4 ) { return -1; }
  for ( k1 = 0; k1 < 13; k1++ ) {
    if ( remain_card.num[k1] >= 1 ) { len++; }
    else { len = 0; }
    if ( len >= 5) { flag = 1; }
  }
  if ( flag ) { return straight(hd, remain_card, hand_card, deck_card, cg); }
  flag = 0;
  if ( poker_point(hand) >= P5 ) { return -1; }
  for ( k1 = 0; k1 < 4; k1++ ) {
    if ( remain_card.sut[k1] >= 5 ) { flag = 1; }
  }
  if ( flag ) {
    disc_num = flush(hd, hand_card, deck_card, cg);
    return disc_num;
  }
  if ( poker_point(hand) >= P6 ) { return -1; }
  for (k1 = 0; k1 < HNUM; k1++ ) {
    if ( remain_card.num[hd[k1].num] == 1 ) { return k1; }
  }
  for (k1 = 0; k1 < HNUM; k1++ ) {
    if ( remain_card.num[hd[k1].num] == 2 ) { return k1; }
  }
  return disc_num;
}
int flush(Handcard hd[], Cards hand_card, Cards deck_card, int cg)
{
  int max_sut;
  int k, k1, k2;
  double exp_num[4] = {0};
  int reqire_num;
  int change_num = CHNG - cg;
  double denominator;
  double numerator;
  for ( k1 = 0; k1 < 4; k1++ ) {
    reqire_num = HNUM - hand_card.sut[k1];
    numerator = 0;
    if ( change_num < reqire_num || deck_card.sut[k1] < reqire_num ) { continue; }
    if ( deck_card.amount < change_num ) {
      exp_num[k1] = 1;
    } else {
      for ( k2 = reqire_num; k2 <= change_num; k2++ ) {
        numerator += combination(deck_card.sut[k1], k2) * combination(deck_card.amount - deck_card.sut[k1], change_num - k2);
      }
      denominator = permutation(deck_card.amount, change_num);
      exp_num[k1] = permutation(change_num, change_num) * numerator / denominator;
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hd[k1].exp[5] = (exp_num[hd[k1].sut] * P5);
  }
  bubble_sort_role(hd, HNUM, 5);
  return hd[0].pos;
}
int pair(Handcard hd[], Cards hand_card, Cards deck_card, Cards remain_card)
{
  int disc_num = -1;
  int k1, k2, k;
  int two_pair = 0;
  for ( k = 0; k < 13; k++ ) {
    if ( hand_card.num[k] == 2 ) { two_pair++; }
  }
  if ( two_pair == 2 ) {
    for ( k = 0; k < HNUM; k++) {
      if ( hand_card.num[hd[k].num] == 1 ) { return k; }
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    if ( remain_card.num[hd[k1].num] == 1 ) { return hd[k1].pos; }
  }
  for ( k1 = 0; k1 < HNUM-1; k1++ ) {
    for ( k2 = k1+1; k2 < HNUM; k2++ ) {
      if ( hand_card.num[hd[k1].num] == 1 && hand_card.num[hd[k2].num] == 1 ) {
        if ( deck_card.num[hd[k1].num] > deck_card.num[hd[k2].num] ) {
          return hd[k2].pos;
        } else {
          return hd[k1].pos;
        }
      }
    }
  }
  for ( k = 0; k < HNUM; k++ ) {
    if ( hand_card.num[hd[k].num] == 1 ) { return k; }
  }
  return disc_num;
}
int straight(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg)
{
  int k1, k2, num;
  double exp_num[13] = {0};
  double prob;
  int reqire_num;
  int change_num = CHNG - cg;
  if ( check_straight(remain_card, hand_card) ) {
    for ( k1 = 0; k1 < HNUM - 1; k1++ ) {
      for ( k2 = k1+1; k2 < HNUM; k2++ ) {
        if ( hd[k1].num == hd[k2].num ) {
          if ( hand_card.sut[hd[k1].sut] < hand_card.sut[hd[k2].sut]) { return k1; }
          else { return k2; }
        }
      }
    }
  }
  for ( k1 = 0; k1 < 10; k1++ ) {
    prob = 1;
    reqire_num = 0;
    for ( k2 = k1; k2 < k1 + 5; k2++ ) {
      if ( k2 == 13 ) { num = 0; }
      else { num = k2; }
      if ( hand_card.num[num] == 0 ) {
        prob *= ((double)deck_card.num[num] / deck_card.amount);
        reqire_num++;
      }
    }
    if ( reqire_num > change_num ) { prob = 0; }
    for ( k2 = k1; k2 < k1 + 5; k2++ ) {
      if ( k2 == 13 ) { num = 0; }
      else { num = k2; }
      exp_num[num] += prob;
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hd[k1].exp[4] += (exp_num[hd[k1].num] * P4);
  }
  bubble_sort_role(hd, HNUM, 4);
  return hd[0].pos;
}
int straight_flush(Handcard hd[], Cards hand_card, Cards deck_card, int cg)
{
  int flag = 0, exist_flag;
  int k1, k2, k3, num;
  int reqire_num;
  int change_num = CHNG - cg;
  double exp_num[4][13] = {0};
  double numerator, denominator;
  double prob;
  for ( k1 = 0; k1 < 4; k1++ ) {
    for ( k2 = 0; k2 < 10; k2++ ) {
      exist_flag = 1;
      reqire_num = 0;
      for ( k3 = k2; k3 < k2 + 5; k3++ ) {
        if ( k3 == 13 ) { num = 0; }
        else { num = k3; }
        if ( hand_card.card[k1][num] == 0 ) {
          reqire_num++;
          if ( deck_card.card[k1][num] == 0 ) { exist_flag = 0; }
        }
      }
      if ( reqire_num > change_num || exist_flag == 0 ) { continue; }
      flag = 1;
      if ( deck_card.amount < change_num ) {
        prob = 1;
      } else {
        numerator = combination(deck_card.amount - reqire_num, change_num - reqire_num);
        denominator = combination(deck_card.amount, change_num);
        prob = numerator / denominator;
      }
      for ( k3 = k2; k3 < k2 + 5; k3++ ) {
        if ( k3 == 13 ) { num = 0; }
        else { num = k3; }
        exp_num[k1][num] += prob;
      }
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hd[k1].exp[8] = (exp_num[hd[k1].sut][hd[k1].num] * P8);
  }
  if ( flag ) {
    bubble_sort_role(hd, HNUM, 8);
    for ( k1 = 0; k1 < HNUM-1; k1++ ) {
      for ( k2 = k1+1; k2 < HNUM; k2++ ) {
        if ( fabs(hd[k1].exp[8]) <= 0 && fabs(hd[k2].exp[8]) <= 0 ) {
          if ( deck_card.num[hd[k1].num] < deck_card.num[hd[k2].num] ) {
            return hd[k1].pos;
          } else {
            return hd[k2].pos;
          }
        }
      }
    }
    return hd[0].pos;
  }
  return -1;
}
int four_of_a_kind(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg)
{
  int k1, k2;
  int reqire_num;
  int change_num = CHNG - cg;
  int min_num;
  int min_pos;
  int flag = 0;
  double exp_num[13] = {0};
  double numerator, denominator;
  for ( k1 = 0; k1 < 13; k1++) {
    reqire_num = 4 - hand_card.num[k1];
    if ( deck_card.num[k1] < reqire_num || change_num < reqire_num ) { continue; }
    flag = 1;
    if ( deck_card.amount < change_num ) {
      exp_num[k1] = 1;
    } else {
      denominator = combination(deck_card.amount, change_num);
      numerator = combination(deck_card.amount - deck_card.num[k1], change_num - reqire_num);
      exp_num[k1] = numerator / denominator;
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hd[k1].exp[7] = (exp_num[hd[k1].num] * P7);
  }
  if ( flag ) {
    bubble_sort_role(hd, HNUM, 7);
    min_num = remain_card.num[hd[0].num];
    min_pos = hd[0].pos;
    for ( k1 = 1; k1 < HNUM; k1++ ) {
      if ( remain_card.num[hd[k1].num] < min_num ) {
        min_num = remain_card.num[hd[k1].num];
        min_pos = hd[k1].pos;
      }
    }
    return min_pos;
  }
  return -1;
}
int royal_straight_flush(Handcard hd[], Cards remain_card, Cards deck_card, int cg)
{
  int k1, k2, num;
  int reqire_num;
  int change_num = CHNG - cg;
  int flag = 0, valid_flag = 0;
  double denominator;
  double numerator;
  double exp_num[4][13] = {0};
  for ( k1 = 0; k1 < 4; k1++ ) {
    reqire_num = 0;
    for ( k2 = 9; k2 < 14; k2++ ) {
      if ( k2 == 13 ) { num = 0; }
      else { num = k2; }
      if ( deck_card.card[k1][num] == 1 ) { reqire_num++; }
      if ( remain_card.card[k1][num] == 0 ) { flag = 0; break; }
      flag = 1;
    }
    if ( flag ) {
      valid_flag = 1;
      numerator = combination(deck_card.amount - reqire_num, change_num- reqire_num);
      denominator = combination(deck_card.amount, change_num);
      for ( k2 = 9; k2 < 14; k2++ ) {
        if ( k2 == 13 ) { num = 0; }
        else { num = k2; }
        if ( deck_card.amount < change_num ) { exp_num[k1][num] = 1; }
        else { exp_num[k1][num] = numerator / denominator; }
      }
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hd[k1].exp[9] = (exp_num[hd[k1].sut][hd[k1].num] * P9);
  }
  if ( valid_flag ) {
    bubble_sort_role(hd, HNUM, 9);
    for ( k1 = 0; k1 < HNUM-1; k1++ ) {
      for ( k2 = k1+1; k2 < HNUM; k2++ ) {
        if ( fabs(hd[k1].exp[9]) <= 0 && fabs(hd[k2].exp[9]) <= 0 ) {
          if ( deck_card.num[hd[k1].num] < deck_card.num[hd[k2].num] ) {
            return hd[k1].pos;
          } else {
            return hd[k2].pos;
          }
        }
      }
    }
    return hd[0].pos;
  }
  return -1;
}
int full_house(Handcard hd[], Cards remain_card, Cards hand_card, Cards deck_card, int cg)
{
  int k1, k2;
  int reqire_num1;
  int reqire_num2;
  int change_num;
  int min_num;
  int min_pos;
  int flag = 0;
  double exp_num[13] = {0};
  double numerator, denominator;
  double prob;
  for ( k1 = 0; k1 < 12; k1++) {
    change_num = CHNG - cg;
    if ( remain_card.num[k1] < 2 ) { continue; }
    reqire_num1 = 2 - hand_card.num[k1];
    for ( k2 = 1; k2 < 13; k2++ ) {
      numerator = 1;
      if ( remain_card.num[k2] < 3 ) { continue; }
      reqire_num2 = 3 - hand_card.num[k2];
      if ( reqire_num1 + reqire_num2 > change_num ) { continue; }
      if ( change_num > deck_card.amount ) {
        prob = 1;
      } else {
        if ( reqire_num1 != 0 ) { numerator *= combination(deck_card.num[k1], reqire_num1); }
        if ( reqire_num2 != 0 ) { numerator *= combination(deck_card.num[k2], reqire_num2); }
        if ( reqire_num1 + reqire_num2 != change_num ) {
          numerator *= combination(deck_card.amount - deck_card.num[k1] - deck_card.num[k2], change_num - reqire_num1 - reqire_num2);
        }
        denominator = permutation(change_num, change_num) / permutation(deck_card.amount, change_num);
        prob = numerator * denominator;
      }
      flag = 1;
      exp_num[k1] += prob; exp_num[k2] += prob;
    }
    if ( remain_card.num[k1] < 3 ) { continue; }
    reqire_num1 = 3 - hand_card.num[k1];
    for ( k2 = 1; k2 < 13; k2++ ) {
      numerator = 1;
      if ( remain_card.num[k2] < 2 ) { continue; }
      reqire_num2 = 2 - hand_card.num[k2];
      if ( reqire_num1 + reqire_num2 > change_num ) { continue; }
      if ( change_num > deck_card.amount ) {
        prob = 1;
      } else {
        if ( reqire_num1 != 0 ) { numerator *= combination(deck_card.num[k1], reqire_num1); }
        if ( reqire_num2 != 0 ) { numerator *= combination(deck_card.num[k2], reqire_num2); }
        if ( reqire_num1 + reqire_num2 != change_num ) {
          numerator *= combination(deck_card.amount - deck_card.num[k1] - deck_card.num[k2], change_num - reqire_num1 - reqire_num2);
        }
        denominator = permutation(change_num, change_num) / permutation(deck_card.amount, change_num);
        prob = numerator * denominator;
      }
      flag = 1;
      exp_num[k1] += prob; exp_num[k2] += prob;
    }
  }
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    hd[k1].exp[6] = (exp_num[hd[k1].num] * P6);
  }
  if ( flag == 1 ) {
    bubble_sort_role(hd, HNUM, 6);
    return hd[0].pos;
  }
  return -1;
}
void bubble_sort_role(Handcard hd[], int n, int role)
{
  int i, j;
  Handcard t;
  for ( i = 0; i < n -1; i++ ) {
    for ( j = n -1; j > i; j-- ) {
      if ( hd[j-1].exp[role] > hd[j].exp[role] ) {
        t = hd[j];
        hd[j] = hd[j-1];
        hd[j-1] = t;
      }
    }
  }
}
int check_straight(Cards remain_card, Cards hand_card)
{
  int len;
  int k1, k2;
  int wait_num = 0;
  for ( k1 = 0; k1 < 13; k1++ ) {
    if ( hand_card.num[k1] == 0 && remain_card.num[k1] != 0 ) {
      len = 0;
      hand_card.num[k1] = 1;
      for ( k2 = 0; k2 < 13; k2++) {
        if ( hand_card.num[k2] >= 1 ) { len++; }
        else { len = 0; }
        if ( k2 == 12 && len == 4 && hand_card.num[0] == 1 ) {
          wait_num += remain_card.num[k1];
        }
        if ( len == 5 ) { wait_num += remain_card.num[k1]; }
      }
      hand_card.num[k1] = 0;
    }
  }
  if ( wait_num >= 1 ) { return wait_num; }
  return 0;
}
double combination(int n, int m)
{
  double c_num = 1;
  int i;
  if ( n < m || n < 0 || m < 0 ) { return 0; }
  for ( i = 1; i <= m ; i++ ) {
    c_num *= (n - i + 1.0) / i;
  }
  return c_num;
}
double permutation(int n, int m)
{
  double c_num = 1;
  int i;
  if ( n < m ) { return 0; }
  for ( i = 1; i <= m; i++ ) {
    c_num *= (n - i + 1.0);
  }
  return c_num;
}
void sum_exps(Handcard hd[], int tk)
{
  int k1, k2;
  double exp;
  for ( k1 = 0; k1 < HNUM; k1++ ) {
    for ( k2 = 0; k2 < 10; k2++ ) {
      exp = hd[k1].exp[k2];
      if ( k2 == 4 ) { exp *= 13.375; }
      if ( k2 == 6 ) { exp /= 10; }
      if ( tk == 4 ) { exp *= 2; }
      if ( tk == 3 || tk == 2 ) { exp *= 1.5; }
      hd[k1].exp[10] += exp;
    }
  }
}