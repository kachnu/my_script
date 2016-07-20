#!/usr/bin/env python3

import csv
import urllib.request
from bs4 import BeautifulSoup


def get_html(url):
    response = urllib.request.urlopen(url)
    return response.read()


def get_page_count(html):
    soup = BeautifulSoup(html, "html5lib")
    paggination = soup.find('div', class_="nav clearfix").find_all('a')[-2].text
    return int(paggination)


def parse(html):
    soup = BeautifulSoup(html, "html5lib")
    table = soup.find('table', class_="forumline forum")
    projects = []
    find_tr = table.find_all('tr', class_='hl-tr')

    for row in find_tr:
        cols = row.find_all('td')
        projects.append({
            'theme': cols[1].a.text,
            'value': cols[2].text.strip().replace('\xa0', ' '),
            'total_answer': cols[3].p.span.text,
            'last_post': cols[4].p.text
        })

    return projects


def save(projects, path):
    with open(path, 'w') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(('Тема', 'Объем', 'Всего постов', 'Последний пост'))

        for project in projects:
            writer.writerow((project['theme'], project['value'], project['total_answer'], project['last_post']))


def main():
    # main_url = 'http://rutracker.org/forum/viewforum.php?f=1379'
    main_url = 'http://rutracker.org/forum/viewforum.php?f=101'
    page_count = get_page_count(get_html(main_url))
    print('Всего страниц -', page_count)

    projects = []

    for page in range(1, page_count + 1):
        print('Старница %s' % page, end=' ')
        print('Парсинг %d%%' % (page / page_count * 100))
        if page == 1:
            html = get_html(main_url)
        else:
            html = get_html(main_url + '&start=' + str((page - 1) * 50))
        projects.extend(parse(html))

    n = 0
    for project in projects:
        print(n, project)
        n += 1

    save(projects, 'projects.csv')

if __name__ == '__main__':
    main()
