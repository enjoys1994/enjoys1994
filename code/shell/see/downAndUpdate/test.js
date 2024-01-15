const https = require("https");
const fs = require("fs");
const { execSync }  =require("child_process")

const projectPath = "/01standard/os/SEE2.0-paasV202306/SEE2.0-paasV202306.01.000";
const repositoryName="see2.0-generic-test-local"
const service = "https://dev.hundsun.com/frameV2/pms/workbench";
// 用于过滤linux最新版本
const linuxRegx = /SEE2.0-linux-V([0-9-]+).zip/
// 本地下载路径
const downloadLocalPath = `/Users/wgy/Downloads/upgrade`
const user = "wanggy29750";
const password  ="Wgyt02756";

start()

async function start() {
  await startDownload()
}

async function startDownload() {
  const {params, url} = await getCasLoginHtml();
  const ticket = await getCasLoginTicket(params , url);
  const token = await getToken(ticket);
  const packageNamePath = await getArtifactory(token);
  const falg = removeLastVersion(packageNamePath);
  if(!falg) return false
  await saveArtifactDownloadRecored(token, packageNamePath)
  const apiKey = await createAPIKey(token, repositoryName)
  await download(apiKey, repositoryName, packageNamePath)
}

async function getCasLoginHtml() {
  const result = await fetch("https://hs-cas.hundsun.com/cas/login?service="+service, {
    "method": "GET"
  })
  const html = await result.text()
  const url = html.match(/action="(.+)" /g)[0].replace("action=","").replace(" ","").replace("\"","")
  const inputs = html.match(/<input type="hidden" name=(.+) value=(.+)/g)
  // const inputs = result.data.match(/<input type="hidden" name=(.+) value=(.+)/g)
  const params = {
    username: user,
    password: password,
    submit: ""
  }

  inputs.forEach(inputStr => {
    const name = inputStr.match(/name="(.\w+)"/)[1];
    const value = inputStr.match(/value="(.+)"/)[1];
    params[name]=value;
  })
  return {
    params,
    url
  }

}
async function getCasLoginTicket(params,url) {
  const parmasStr = Object.keys(params).reduce((str, key) => {
    const param = `${key}=${params[key]}`
    const nesStr = str ? str + "&"+param : param
    return nesStr
  }, "")
  // console.log(parmasStr)
  const path = "https://hs-cas.hundsun.com"+url
  const result = await fetch(path, {
    "headers": {
      "content-type": "application/x-www-form-urlencoded",
    },
    // maxRedirects: 0,
    redirect: 'manual',
    // data: JSON.stringify(params),
    body: parmasStr,
    // "cookie": "JSESSIONID=E9FB97B1EEEC376DFF0CEEBC7F667D5C.tomcat2",
    "method": "POST",
  })
  const ticket = result.headers.get('location').match(/ticket=(.+)/g)[0].replace("ticket=","");
  log("ticket", ticket)
  return ticket
}
async function getToken(ticket) {
  const result = await fetch("https://dev.hundsun.com/hepucs/auth/casLogin", {

    "headers": {
      "content-type": "application/json",
      "accept": "application/json, text/plain, */*",
    },
    "body": JSON.stringify({
      service,
      ticket
    }),
    "method": "POST"
  })
  const data = await result.json();
  const token = data.data.access_token;
  log("token", token)
  return token
}

async function getArtifactory(token) {
  const params = {
    path: projectPath,
    repo: repositoryName,
    type: "generic",
    file_sort: "CHARACTER_ASC"
  }
  const result = await fetch("https://dev.hundsun.com/hepcore/artifact/queryArtifactStorage", {
    "headers": {
      "authorization": token,
      "content-type": "application/json",
    },
    "body": JSON.stringify(params),
    "method": "POST"
  });
  const data = await result.json();
  const filterData = data.data.children.filter(item => {
    return item.uri.slice(1).match(linuxRegx)
  }).map(item => item.uri)
  const packageNamePath = filterData.pop();
  log("packageNamePath", packageNamePath)
  return packageNamePath.slice(1);
}

async function saveArtifactDownloadRecored(userToken,packageNamePath) {
  const url = "https://dev.hundsun.com/hepcore/artifactOperate/saveArtifactDownloadRecored";
  const repositoryNameParams = "repositoryName=see2.0-generic-test-local";
  const pathParams = `path=${projectPath}/${packageNamePath}`;
  const tokenParams = `token=${userToken}`
  const uri =  `${url}?${repositoryNameParams}&${pathParams}&${tokenParams}`
  const result = await fetch(uri, {
    "headers": {
      "authorization": userToken,
    },
    "method": "GET"
  });
  const data = await result.json();
}
async function createAPIKey(token) {
  const result = await fetch("https://dev.hundsun.com/hepcore/artifact/createAPIKey", {
    "headers": {
      "authorization": token,
      "content-type": "application/json",
    },
    "body": "{\"regenerate\":false}",
    "method": "POST"
  });
  const data = await result.json()
  const apiKey = data.data.api_key;
  log("apiKey", apiKey)
  return apiKey
}

async function download(apiKey, repositoryName, packageNamePath) {
  const timestamp = +new Date();
  const url = `https://package.hundsun.com/download/${apiKey}/artifactory/${repositoryName}${projectPath}/${packageNamePath}?timestamp=${timestamp}`
  const filePath = `${downloadLocalPath}/${packageNamePath}`
  log("downloadUrl", url)
  log("", `start download package ${packageNamePath}`)
  return new Promise(async resolve => {
    const filePathStream = fs.createWriteStream(filePath);
    https.get(url, res => {
      res.pipe(filePathStream)
      // 进度
      const len = parseInt(res.headers['content-length']) // 文件总长度
      let cur = 0
      const total = (len / 1024).toFixed(2) // 转为kb 1024
      res.on('data', function (chunk) {
        cur += chunk.length
        const progress = (100.0 * cur / len).toFixed(2) // 当前进度
        const currProgress = (cur / 1024).toFixed(2) // 当前了多少
        log('download', `进度：${progress}%,当前：${currProgress}kb,总共：${total}kb`)
      })
      filePathStream.on("finish", (error) => {
        if(error) {
          console.log(error)
        }
        log("download", `success download ${packageNamePath}`)
        filePathStream.close();
        resolve(packageNamePath);
      }).on("error", (err) => {
        console.log(err)
        fs.unlink(filePath)
      }).on("close", (err) => {
        if(err) {
          console.log(err)
        }
      }).on("end",(err) => {
        if(err) {
          console.log(err)
        }
      })
    }).on("error",(err) => {
      if(err) {
        console.log(err)
      }
    })
  })

}


function log(key, message) {
  console.log(`【${new Date()}】${key}：${message}`)
}

function removeFile(target) {
  let stat = fs.statSync(target);
  if(!stat.isDirectory()) {
    fs.unlinkSync(target);
  }
}

function isNeedUpdate(filterFiles, lastVersion) {
  const sortFiles = filterFiles.sort();
  const sortLastVersion = sortFiles.pop();
  if(sortLastVersion === lastVersion) {
    log("", `${lastVersion} is not last version`);
    return false
  }
  return true
}

function removeLastVersion(lastVersion) {
  const files = fs.readdirSync(downloadLocalPath);
  const filterFiles = files.filter(item => {
    return `${item}`.match(linuxRegx)
  });
  const flag = isNeedUpdate(filterFiles, lastVersion)
  if(!flag) return
  filterFiles.forEach(item => {
    removeFile(`${downloadLocalPath}/${item}`)
  })
  return true
}
