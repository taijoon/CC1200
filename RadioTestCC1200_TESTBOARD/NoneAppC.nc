/*
 * Copyright (c) 2010-2013 Sinbinet Corp.
 * All rights reserved.
 */

/**
 * @author Sukun Kim <sukunkim@sinbinet.com>
 */

configuration NoneAppC
{
}

implementation
{
  components NoneC,
    MainC;
  NoneC.Boot -> MainC;

  components RadioTestC;
  RadioTestC.Boot -> MainC;
}

