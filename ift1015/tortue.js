const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

const codeboot = "http://www-labs.iro.umontreal.ca/~codeboot/codeboot";

// XXX
const dirs = d => fs.readdirSync(d)
    .map(f => path.join(d, f))
    .filter(f => fs.statSync(f).isDirectory());

// XXX
let files = dirs("Ex6").map(d => path.join(d, fs.readdirSync(d)[0]));

const links = files.map(file => {
    const data = fs.readFileSync(file, 'utf8');
    const cleanedData = data.replace(/﻿|\r/g, "");
    const encodedData = `@C${file}@0${cleanedData.replace(/\n/g, "@N")}@E`;
    const base64Data = Buffer.from(encodedData).toString('base64');

    return `${codeboot}/query.cgi?REPLAY=${base64Data}`;
});

puppeteer.launch({
    args: ['--no-sandbox'],
    headless: false,
}).then(async browser => {
    const page = await browser.newPage();
    page.on('dialog', async dialog => {
        await dialog.accept();
    });

    // Switch to standard mode
    await page.goto(codeboot, {waitUntil: 'networkidle2'});
    await page.click('.fa-cogs');
    await page.click('a[data-cb-setting-level="standard"]');

    for (let link of links) {
        await page.goto(link, {waitUntil: 'networkidle2'});
        await page.click('#cb-exec-btn-eval');

        const img = await page.$('#cb-drawing-window-turtle');
        if (img) {
            await img.screenshot({
                path: files[links.indexOf(link)].replace(/\.js$/i, ".png") // XXX
            });
        }
    }

    await browser.close();
});
