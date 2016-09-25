#!/usr/bin/env python3
# coding: utf-8

"""
This script reads the table of testimonies from an excel file in the wiki
and writes it to a simple HTML table.


Attributes:

    selected_columns (list): Labels of the columns in the original table that should be selected.
    column_labels (list): New labels for the selected_columns

"""

selected_columns = ['Gräf-Nr.', 'Pniower-Nr.', 'Datum.(von)', 'Dokumenttyp', 'Verfasser', 'Adressat', 'Druckort']
column_labels = ['Gräf', 'Pniower', 'Datum', 'Quellengattung', 'Verfasser', 'Adressat', 'Druckort']


import pandas as pd
from lxml import html
import requests
from getpass import getpass
import io

def fetch_table():
    """
    Fetches the excel file from the wiki, interactively asking for a password
    """
    api = "https://faustedition.uni-wuerzburg.de/wiki/api.php"
    xlsurl = "https://faustedition.uni-wuerzburg.de/wiki/images/b/b5/Dokumente_zur_Entstehungsgeschichte.xls"
    lguser = input("Wiki User: ")
    lgpass = getpass("Wiki Password: ")

    s = requests.Session()
    s.verify = False

    loginparams = dict(
        lgname=lguser,
        lgpassword=lgpass,
        action='login',
        format='json')
    login1 = s.post(api, params=loginparams)
    token = login1.json()['login']['token']
    loginparams["lgtoken"] = token
    s.post(api, params=loginparams)
    response = s.get(xlsurl, params=dict(token=token))
    return io.BytesIO(response.content)

def read_testimonies(buf, **kwargs):
    """
    Reads the table from the given object and filters the interesting columns.

    Args:
        buf: cf. :func:`pd.read_excel`
        kwargs: passed on to pandas

    Returns:
        pd.DataFrame
    """
    raw_testimonies = pd.read_excel(buf, **kwargs)
    testimonies = raw_testimonies[selected_columns]
    testimonies.columns = pd.Index(column_labels)
    testimonies.loc[:,'Datum'] = testimonies.loc[:,'Datum'].str.replace('00\.', '')
    return testimonies


def html_table(testimony_df):
    """
    Converts the dataframe to an HTML table, and adds appropriate attributes.
    """
    table = html.fromstring(testimony_df.to_html(na_rep='', index=False))

    table.attrib['data-sortable'] = 'true'
    table.attrib['class'] = 'pure-table'
    headerrow = table.find('thead').find('tr')
    del headerrow.attrib['style']
    ths = headerrow.findall('th')
    for th in ths:
        th.attrib['data-sorted'] = 'false'
        if th.text in ['Gräf', 'Pniower']:
            th.attrib['data-sortable-type'] = 'numericplus'
        elif th.text == 'Datum':
            th.attrib['data-sortable-type'] = 'date-de'
        elif th.text == 'Druckort':
            th.attrib['data-sortable-type'] = 'bibliography'
        else:
            th.attrib['data-sortable-type'] = 'alpha'
    return table

def test():
    table = html_table(read_testimonies('Dokumente_zur_Entstehungsgeschichte.xls'))
    print(html.tostring(table, encoding="unicode"))


def write_html(output, table):
    prefix = """
<?php $showFooter = false; ?>
<?php /* ATTENTION: This file is generated by get_testimonies.py. DO NOT EDIT HERE */ ?>
<?php include "includes/header.php"; ?>
<section>

  <article>
      <div id="testimony-table-container">
"""
    suffix = """
      </div>
  </article>

</section>
<script type="text/javascript">
  // set breadcrumbs
  document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv", link: "archive"}, {caption: "Dokumente zur Entstehungsgeschichte"}]));
</script>

<?php include "includes/footer.php"; ?>
"""
    with open(output, mode="wt", encoding="utf-8") as out:
        out.write(prefix)
        out.write(html.tostring(table, encoding="unicode"))
        out.write(suffix)

def main():
    pd.set_option('max_colwidth', 10000)
    df = read_testimonies(fetch_table())
    write_html("src/main/web/archive_testimonies.php", html_table(df))

if __name__ == '__main__':
    main()
