<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use DB;
use Log;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    // public function __construct()
    // {
    //     $this->middleware('auth');
    // }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        return view('home');
    }

    public function send_message(Request $request)
    {
        $data = $request->except('_token');
        // dd($data);
        // $result = $this->process_send_message($data);


        $_data = ['msg' => "Sorry, I ain't taking your messages from this website yet. Please use my email to reach out to me!"];

        return response()->json($_data);
    }

    public function process_send_message( $_data )
    {
        throw new Exception("Sorry, I ain't taking your messages from this website yet. Please use my email to reach out to me!", 1);
        try {
            //send mail to my email account            
            $_mail = [
                'body' => $_data->message,
                'thanks' => 'Thank you',
            ];

            // Notification::send($user, new RequisitionNotification($_new_reqn_mail));
            $status = true;
            $message = 'Your message has been sent';
        } catch (Exception $e) {
            $status = false;
            $message = 'Sorry, Your message has not been sent';
            Log::info($message.' Reason => '.$ex->getMessage().';...Trace => '.$ex->getTraceAsString() );            
        }

    }
}
