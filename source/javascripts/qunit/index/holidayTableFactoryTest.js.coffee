#= require index/tableFactory
#= require qunit/helpers

replaceWhitespaceBetweenHtmlTags = (string) -> string.replace(/\>\s+\</g, '><')

holidayTableTest = (gregorianDate, actualHtml, expectedHtml, tableIterator) ->
    QUnit.test "Holiday Table #{tableIterator + 1} for week of #{gregorianDate}", (assert) ->
      assert.equal actualHtml, expectedHtml

holidayTablesTest = (gregorianDate, expectedHtmlArray) ->
  factory = new TableFactory(gregorianDate)
  actualHtmlArray = factory.generateHolidayTables()
  QUnit.test "The right number of Holiday Tables are generated for week of #{gregorianDate}", (assert) ->
    assert.equal actualHtmlArray.length, expectedHtmlArray.length
  for i in [0...(actualHtmlArray.length)]
    actualHtml = replaceWhitespaceBetweenHtmlTags(actualHtmlArray[i])
    expectedHtml = replaceWhitespaceBetweenHtmlTags(expectedHtmlArray[i])
    holidayTableTest(gregorianDate, actualHtml, expectedHtml, i)

EXPECTED_2021_SEPT_14 = [
  """
    <table class='table table-striped table-condensed'>
       <thead>
          <tr>
             <th colspan=4 class='text-center'>
            יוֹם הַכִּפֻּרִים
          </th>
          </tr>
       </thead>
       <tbody>
          <tr>
             <td rowspan='1'>Wednesday</td>
             <td rowspan='1'>15 Sep</td>
             <td>הַדְלַקָת נֵרוֹת</td>
             <td>7:08</td>
          </tr>
          <tr>
             <td rowspan='5'>Thursday</td>
             <td rowspan='5'>16 Sep</td>
             <td>נְעִילָה</td>
             <td>6:30</td>
          </tr>
          <tr>
             <td>בִּרְכַּת כֹּהֲנִים before</td>
             <td>7:25</td>
          </tr>
          <tr>
             <td>שׁוֹפַר</td>
             <td>7:59</td>
          </tr>
          <tr>
             <td colspan=2 class='text-center'><strong>No eating before הַבְדָלָה</strong></td>
          </tr>
          <tr>
             <td>רַבֵּנוּ תָּם</td>
             <td>8:38</td>
          </tr>
       </tbody>
    </table>
  """,
  """
      <table class='table table-striped table-condensed'>
         <thead>
            <tr>
               <th colspan=4 class='text-center'>
              שַׁבָּת
            </th>
            </tr>
         </thead>
         <tbody>
            <tr>
               <td rowspan='1'>Friday</td>
               <td rowspan='1'>17 Sep</td>
               <td>הַדְלַקָת נֵרוֹת</td>
               <td>7:06</td>
            </tr>
            <tr>
               <td rowspan='5'>שַׁבָּת</td>
               <td rowspan='5'>18 Sep</td>
               <td><strong>Say שְׁמַע יִשְׂרָאֵל before</strong></td>
               <td><strong>9:36</strong></td>
            </tr>
            <tr>
               <td>Afternoon Shiurim</td>
               <td>5:05 / 5:35</td>
            </tr>
            <tr>
               <td><span class='font13'>Begin סְעוּדַת שְׁלִישִׁית before</span></td>
               <td>7:23</td>
            </tr>
            <tr>
               <td>שַׁבָּת ends</td>
               <td>7:57</td>
            </tr>
            <tr>
               <td>רַבֵּנוּ תָּם</td>
               <td>8:36</td>
            </tr>
         </tbody>
      </table>
  """
]

$ ->
  # Yom Kippur on a Thursday
  holidayTablesTest(new Date(2021,8,14), EXPECTED_2021_SEPT_14)
