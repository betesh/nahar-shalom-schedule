#= require index/tableFactory
#= require qunit/helpers

replaceWhitespaceBetweenHtmlTags = (string) -> string.replace(/\>\s+\</g, '><')

weekTableTest = (gregorianDate, expectedHtml) ->
  factory = new TableFactory(gregorianDate)
  actualHtml = factory.generateWeekTable()
  expectedHtml = replaceWhitespaceBetweenHtmlTags(expectedHtml)
  actualHtml = replaceWhitespaceBetweenHtmlTags(actualHtml)
  QUnit.test "During week of #{gregorianDate}", (assert) ->
    assert.equal actualHtml, expectedHtml

EXPECTED_2016_MAY_14 = """
  <thead><tr>
    <th></th>
    <th></th>
    <th></th>
    <th>קָרְבָּנוֹת</th>
    <th>הוֹדוּ</th>
    <th>יִשְׁתַּבַּח</th>
    <th>עֲמִידָה</th>
    <th>מִנְחָה</th>
    <th>עַרְבִית</th>
    <th>סְפִירַת הָעֹמֶר</th>
  </tr></thead>
  <tbody><tr>
    <td>Sunday</td>
    <td>15 May</td>
    <td>אִיָּר 7</td>
    <td>5:58</td>
    <td>6:14</td>
    <td>6:25</td>
    <td class='bold'>6:34:25</td>
    <td>7:46</td>
    <td>8:00</td>
    <td>Sun. night: <b>23</b> (After 8:17)</td>
  </tr>
  <tr>
    <td>Monday</td>
    <td>16 May</td>
    <td>אִיָּר 8</td>
    <td>5:57</td>
    <td>6:13</td>
    <td>6:25</td>
    <td class='bold'>6:33:55</td>
    <td>7:46</td>
    <td>8:01</td>
    <td>Mon. night: <b>24</b> (After 8:18)</td>
  </tr>
  <tr>
    <td>Tuesday</td>
    <td>17 May</td>
    <td>אִיָּר 9</td>
    <td>5:57</td>
    <td>6:13</td>
    <td>6:24</td>
    <td class='bold'>6:33:25</td>
    <td>7:46</td>
    <td>8:01</td>
    <td>Tue. night: <b>25</b> (After 8:18)</td>
  </tr>
  <tr>
    <td>Wednesday</td>
    <td>18 May</td>
    <td>אִיָּר 10</td>
    <td>5:57</td>
    <td>6:13</td>
    <td>6:24</td>
    <td class='bold'>6:33:00</td>
    <td>7:46</td>
    <td>8:02</td>
    <td>Wed. night: <b>26</b> (After 8:19)</td>
  </tr>
  <tr>
    <td>Thursday</td>
    <td>19 May</td>
    <td>אִיָּר 11</td>
    <td>5:56</td>
    <td>6:12</td>
    <td>6:24</td>
    <td class='bold'>6:32:35</td>
    <td>7:46</td>
    <td>8:03</td>
    <td>Thu. night: <b>27</b> (After 8:19)</td>
  </tr>
  <tr>
    <td>Friday</td>
    <td>20 May</td>
    <td>אִיָּר 12</td>
    <td>5:56</td>
    <td>6:12</td>
    <td>6:23</td>
    <td class='bold'>6:32:10</td>
    <td>6:30</td>
    <td></td>
    <td>Fri. night: <b>28</b> (After 8:20)</td>
  </tr>
  <tr>
    <td>שַׁבָּת</td>
    <td>21 May</td>
    <td>אִיָּר 13</td>
    <td><span class='screen-only'><a href='shabbat.html'>5:36</a> and </span>8:15</td>
    <td><span class='screen-only'><a href='shabbat.html'>5:51</a> and </span>8:30</td>
    <td></td>
    <td class='bold'><span class='screen-only'><a href='shabbat.html'>6:31:45</a></td>
    <td>7:15</td>
    <td>8:52</td>
    <td>Sat. night: <b>29</b> (After 8:20)</td>
  </tr></tbody>
"""

EXPECTED_2015_SEPTEMBER_16 = """
  <thead><tr>
    <th></th>
    <th></th>
    <th></th>
    <th>סְלְיחוֹת</th>
    <th>קָרְבָּנוֹת</th>
    <th>הוֹדוּ</th>
    <th>יִשְׁתַּבַּח</th>
    <th>עֲמִידָה</th>
    <th>מִנְחָה</th>
    <th>עַרְבִית</th>
    <th></th>
  </tr></thead>
  <tbody><tr>
    <td>Sunday</td>
    <td>13 Sep</td>
    <td>אֱלוּל 29</td>
    <td>5:39</td>
    <td>6:29</td>
    <td>6:45</td>
    <td>6:57</td>
    <td class='bold'>7:05:30</td>
    <td>6:40</td>
    <td></td>
    <td>הָתַּרָת נְדָרים</td>
  </tr>
  <tr>
    <td>Monday</td>
    <td>14 Sep</td>
    <td>תִּשְׁרִי 1</td>
    <td></td>
    <td><span class='screen-only'><a href='shabbat.html'>6:08</a> and </span>7:45</td>
    <td><span class='screen-only'><a href='shabbat.html'>6:23</a> and </span>8:00</td>
    <td></td>
    <td class='bold'><span class='screen-only'><a href='shabbat.html'>7:05:50</a></td>
    <td>6:25</td>
    <td>7:43</td>
    <td>יוֹם טוֹב</td>
  </tr>
  <tr>
    <td>Tuesday</td>
    <td>15 Sep</td>
    <td>תִּשְׁרִי 2</td>
    <td></td>
    <td><span class='screen-only'><a href='shabbat.html'>6:09</a> and </span>7:45</td>
    <td><span class='screen-only'><a href='shabbat.html'>6:24</a> and </span>8:00</td>
    <td></td>
    <td class='bold'><span class='screen-only'><a href='shabbat.html'>7:06:15</a></td>
    <td>6:45</td>
    <td>7:50</td>
    <td>יוֹם טוֹב</td>
  </tr>
  <tr>
    <td>Wednesday</td>
    <td>16 Sep</td>
    <td>תִּשְׁרִי 3</td>
    <td>5:34</td>
    <td>6:30</td>
    <td>6:46</td>
    <td>6:58</td>
    <td class='bold'>7:06:40</td>
    <td>6:55</td>
    <td>7:25</td>
    <td>צוֹם גְּדַלְיָה</td>
  </tr>
  <tr>
    <td>Thursday</td>
    <td>17 Sep</td>
    <td>תִּשְׁרִי 4</td>
    <td>5:35</td>
    <td>6:31</td>
    <td>6:47</td>
    <td>6:58</td>
    <td class='bold'>7:07:05</td>
    <td>7:05</td>
    <td>7:24</td>
    <td></td>
  </tr>
  <tr>
    <td>Friday</td>
    <td>18 Sep</td>
    <td>תִּשְׁרִי 5</td>
    <td>5:35</td>
    <td>6:31</td>
    <td>6:47</td>
    <td>6:58</td>
    <td class='bold'>7:07:25</td>
    <td>6:30</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>שַׁבָּת</td>
    <td>19 Sep</td>
    <td>תִּשְׁרִי 6</td>
    <td></td>
    <td><span class='screen-only'><a href='shabbat.html'>6:12</a> and </span>7:45</td>
    <td><span class='screen-only'><a href='shabbat.html'>6:27</a> and </span>8:00</td>
    <td></td>
    <td class='bold'><span class='screen-only'><a href='shabbat.html'>7:07:50</a></td>
    <td>6:35</td>
    <td>8:06</td>
    <td></td>
  </tr></tbody>
"""

EXPECTED_2015_SEPTEMBER_23 = """
  <thead><tr>
    <th></th>
    <th></th>
    <th></th>
    <th>סְלְיחוֹת</th>
    <th>קָרְבָּנוֹת</th>
    <th>הוֹדוּ</th>
    <th>יִשְׁתַּבַּח</th>
    <th>עֲמִידָה</th>
    <th>מִנְחָה</th>
    <th>עַרְבִית</th>
    <th></th>
  </tr></thead>
  <tbody><tr>
    <td>Sunday</td>
    <td>20 Sep</td>
    <td>תִּשְׁרִי 7</td>
    <td>5:36</td>
    <td>6:32</td>
    <td>6:48</td>
    <td>6:59</td>
    <td class='bold'>7:08:15</td>
    <td>7:01</td>
    <td>7:21</td>
    <td></td>
  </tr>
  <tr>
    <td>Monday</td>
    <td>21 Sep</td>
    <td>תִּשְׁרִי 8</td>
    <td>5:36</td>
    <td>6:32</td>
    <td>6:48</td>
    <td>7:00</td>
    <td class='bold'>7:08:40</td>
    <td>7:01</td>
    <td>7:19</td>
    <td></td>
  </tr>
  <tr>
    <td>Tuesday</td>
    <td>22 Sep</td>
    <td>תִּשְׁרִי 9</td>
    <td>5:37</td>
    <td>6:33</td>
    <td>6:49</td>
    <td>7:00</td>
    <td class='bold'>7:09:05</td>
    <td>3:30</td>
    <td>6:20</td>
    <td>הָתַּרָת נְדָרים</td>
  </tr>
  <tr>
    <td>Wednesday</td>
    <td>23 Sep</td>
    <td>תִּשְׁרִי 10</td>
    <td></td>
    <td><span class='screen-only'><a href='shabbat.html'>5:59</a> and </span>7:00</td>
    <td><span class='screen-only'><a href='shabbat.html'>6:14</a> and </span>7:15</td>
    <td></td>
    <td class='bold'><span class='screen-only'><a href='shabbat.html'>7:09:30</a></td>
    <td>4:00</td>
    <td>8:02</td>
    <td>יוֹם הַכִּפֻּרִים</td>
  </tr>
  <tr>
    <td>Thursday</td>
    <td>24 Sep</td>
    <td>תִּשְׁרִי 11</td>
    <td></td>
    <td>6:33</td>
    <td>6:49</td>
    <td>7:01</td>
    <td class='bold'>7:09:55</td>
    <td>6:57</td>
    <td>7:16</td>
    <td></td>
  </tr>
  <tr>
    <td>Friday</td>
    <td>25 Sep</td>
    <td>תִּשְׁרִי 12</td>
    <td></td>
    <td>6:34</td>
    <td>6:50</td>
    <td>7:01</td>
    <td class='bold'>7:10:15</td>
    <td>6:30</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>שַׁבָּת</td>
    <td>26 Sep</td>
    <td>תִּשְׁרִי 13</td>
    <td></td>
    <td><span class='screen-only'><a href='shabbat.html'>6:15</a> and </span>7:45</td>
    <td><span class='screen-only'><a href='shabbat.html'>6:30</a> and </span>8:00</td>
    <td></td>
    <td class='bold'><span class='screen-only'><a href='shabbat.html'>7:10:40</a></td>
    <td>6:25</td>
    <td>7:58</td>
    <td></td>
  </tr></tbody>
"""

$ ->
  # Sefirat Haomer
  weekTableTest(new Date(2016,4,15), EXPECTED_2016_MAY_14)

  # Rosh Hashana in middle of week
  weekTableTest(new Date(2015,8,16), EXPECTED_2015_SEPTEMBER_16)

  # Yom Kippuer in middle of week
  weekTableTest(new Date(2015,8,23), EXPECTED_2015_SEPTEMBER_23)
