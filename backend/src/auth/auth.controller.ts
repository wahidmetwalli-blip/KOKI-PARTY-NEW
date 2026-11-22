import {
  Body,
  Controller,
  Get,
  Header,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';

import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  @Get('login-form')
  @Header('Content-Type', 'text/html; charset=utf-8')
  @Header('Cache-Control', 'no-store')
  loginForm() {
    return `<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>KOKI PARTY - تسجيل الدخول</title>
<style>
*{box-sizing:border-box}
body{margin:0;min-height:100vh;background:#100d18;color:#f7f1df;font-family:Arial;display:grid;place-items:center;padding:18px}
main{width:100%;max-width:430px;background:#1d1728;border:1px solid #8e7138;border-radius:18px;padding:24px}
h1{color:#e7c66e;text-align:center}
p{color:#c9bfd2;line-height:1.7;text-align:center}
label{display:block;margin:16px 0 7px;color:#e7c66e}
input{width:100%;padding:14px;border-radius:10px;border:1px solid #594969;background:#100d18;color:white;font-size:16px}
button{width:100%;margin-top:22px;padding:15px;border:0;border-radius:10px;background:#d5ad50;color:#17111e;font-weight:bold;font-size:16px}
button:disabled{opacity:.6}
#result{white-space:pre-wrap;overflow-wrap:anywhere;margin-top:16px;line-height:1.6}
</style>
</head>
<body>
<main>
<h1>KOKI PARTY</h1>
<p>تسجيل دخول المالك</p>
<form id="loginForm">
<label>البريد الإلكتروني أو رقم الهاتف</label>
<input id="identifier" type="text" autocomplete="username" required>
<label>كلمة المرور</label>
<input id="password" type="password" autocomplete="current-password" minlength="8" required>
<button id="submit" type="submit">تسجيل الدخول</button>
</form>
<div id="result" role="status"></div>
</main>
<script>
const form=document.getElementById('loginForm');
const result=document.getElementById('result');
const button=document.getElementById('submit');

form.addEventListener('submit',async event=>{
 event.preventDefault();
 button.disabled=true;
 button.textContent='جاري تسجيل الدخول...';
 result.textContent='';

 try{
  const response=await fetch('/api/auth/login',{
   method:'POST',
   headers:{'Content-Type':'application/json'},
   body:JSON.stringify({
    identifier:document.getElementById('identifier').value.trim(),
    password:document.getElementById('password').value
   })
  });

  const data=await response.json().catch(()=>({message:'استجابة غير مفهومة'}));

  if(!response.ok){
   result.textContent=typeof data.message==='string'?data.message:'بيانات الدخول غير صحيحة.';
   return;
  }

  if(data.access_token){
   sessionStorage.setItem('koki_access_token',data.access_token);
  }

  result.textContent='تم تسجيل الدخول بنجاح.\\nالدور: '+(data.user?.role||'غير محدد')+'\\nمعرّف الحساب: '+(data.user?.id||'غير متاح');
  form.reset();

 }catch(error){
  result.textContent='تعذر الاتصال بالسيرفر. حاول مرة تانية.';
 }finally{
  button.disabled=false;
  button.textContent='تسجيل الدخول';
 }
});
</script>
</body>
</html>`;
  }

  @Get('setup-owner-form')
  @Header('Content-Type', 'text/html; charset=utf-8')
  @Header('Cache-Control', 'no-store')
  setupOwnerForm() {
    return `<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>KOKI PARTY - إنشاء المالك</title>
<style>
*{box-sizing:border-box}
body{margin:0;min-height:100vh;background:#100d18;color:#f7f1df;font-family:Arial;display:grid;place-items:center;padding:18px}
main{width:100%;max-width:430px;background:#1d1728;border:1px solid #8e7138;border-radius:18px;padding:24px}
h1{color:#e7c66e;text-align:center}
p{color:#c9bfd2;line-height:1.7;text-align:center}
label{display:block;margin:16px 0 7px;color:#e7c66e}
input{width:100%;padding:14px;border-radius:10px;border:1px solid #594969;background:#100d18;color:white;font-size:16px}
button{width:100%;margin-top:22px;padding:15px;border:0;border-radius:10px;background:#d5ad50;color:#17111e;font-weight:bold;font-size:16px}
#result{white-space:pre-wrap;overflow-wrap:anywhere;margin-top:16px;line-height:1.6}
</style>
</head>
<body>
<main>
<h1>KOKI PARTY</h1>
<p>إنشاء حساب المالك الأساسي لمرة واحدة فقط. لا تشارك مفتاح الحماية مع أي حد.</p>
<form id="ownerForm">
<label>البريد الإلكتروني</label>
<input id="email" type="email" placeholder="name@example.com">
<label>رقم الهاتف (اختياري)</label>
<input id="phone" type="tel" placeholder="+39...">
<label>كلمة مرور حساب المالك</label>
<input id="password" type="password" minlength="8" required>
<label>مفتاح الحماية الموجود في Render</label>
<input id="setupKey" type="password" required>
<button id="submit" type="submit">إنشاء حساب المالك</button>
</form>
<div id="result"></div>
</main>
<script>
const form=document.getElementById('ownerForm');
const result=document.getElementById('result');
const button=document.getElementById('submit');

form.addEventListener('submit',async event=>{
 event.preventDefault();

 const email=document.getElementById('email').value.trim();
 const phone=document.getElementById('phone').value.trim();
 const password=document.getElementById('password').value;
 const setupKey=document.getElementById('setupKey').value;

 if(!email&&!phone){
  result.textContent='اكتب البريد أو رقم الهاتف.';
  return;
 }

 if(password.length<8){
  result.textContent='كلمة المرور لازم تكون 8 أحرف على الأقل.';
  return;
 }

 button.disabled=true;
 button.textContent='جاري الإنشاء...';
 result.textContent='';

 try{
  const response=await fetch('/api/auth/setup-owner',{
   method:'POST',
   headers:{'Content-Type':'application/json'},
   body:JSON.stringify({email,phone,password,setupKey})
  });

  const data=await response.json().catch(()=>({message:'استجابة غير مفهومة'}));

  result.textContent=response.ok
   ?'تم إنشاء حساب المالك بنجاح.'
   :(data.message||'حصل خطأ أثناء الإنشاء');

  if(response.ok)form.reset();

 }catch(error){
  result.textContent='تعذر الاتصال بالسيرفر. حاول مرة تانية.';
 }finally{
  button.disabled=false;
  button.textContent='إنشاء حساب المالك';
 }
});
</script>
</body>
</html>`;
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('setup-owner')
  @HttpCode(HttpStatus.CREATED)
  async setupOwner(
    @Body()
    dto: {
      email?: string;
      phone?: string;
      password: string;
      setupKey: string;
    } = {
      password: '',
      setupKey: '',
    },
  ) {
    return this.authService.setupOwner(dto);
  }
}
