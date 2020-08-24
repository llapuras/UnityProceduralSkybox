using System;
using UnityEngine;
using UnityEngine.UI;

public class Clock : MonoBehaviour {

	[Header("Date and Time UI")]
	public Text dateUI;

	[Header("Real Time?")]
	public bool realtime = false;

	[Header("Pause Time?")]
	public bool isPause = false;

	[Header("Timespan(min) for One Day")]
	public float minPerDay = 5; //1 day real time = 5 min in game
	private int date = 1;//set initial date

	[Header("Skybox")]
	public GameObject sky;
	private Vector3 skydegree;

	[Header("Transform Setting")]
	public Transform hoursTransform;
	public Transform minutesTransform;
	public Transform secondsTransform;

	[Header("UI Button")]
	public GameObject pauseBtn;
	public GameObject playBtn;

	private float degreesPerHour, degreesPerMinute, degreesPerSecond;
	private double initialHour, initialMinute, initialSecond;
	private double gapHour = 0f, gapMinute = 0f, gapSecond = 0f;
	private bool getStopTime = false;
	private TimeSpan stopTime;
	private double oldTotal;

	void InitialDegrees()
	{
		if (realtime)
		{
			//1 day equals to 5 min, speedup → 24*60/5
			degreesPerHour = 30f;
			degreesPerMinute = 6f;
			degreesPerSecond = 6f;
        }
        else
        {
			//1 day equals to 5 min, speedup → 24*60/5
			degreesPerHour = 30f * (24 * 60 / minPerDay);
			degreesPerMinute = 360f * (24 * 60 / minPerDay);
			degreesPerSecond = 1 * (24 * 60 / minPerDay);
		}
	}

	void InitialTime()
	{
		TimeSpan initialTime = DateTime.Now.TimeOfDay;
		if (realtime)
		{
			initialHour = 0;
			initialMinute = 0;
			initialSecond = 0;
		}
		else
		{
			initialHour = initialTime.TotalHours;
			initialMinute = initialTime.TotalMinutes;
			initialSecond = initialTime.TotalSeconds;
		}
	}
	void GetGapTime()
    {
		TimeSpan currentTime = DateTime.Now.TimeOfDay;

		if (getStopTime == false)
		{
			stopTime = DateTime.Now.TimeOfDay;//get pause time
			getStopTime = true;
		}
	
		gapHour = currentTime.TotalHours - stopTime.TotalHours;//get timespan of current time and pause time
		gapMinute = currentTime.TotalMinutes - stopTime.TotalMinutes;
		gapSecond = currentTime.TotalSeconds - stopTime.TotalSeconds;
	}

	private void Start()
	{
		InitialDegrees();
		InitialTime();
		if (dateUI)
		{
			dateUI.text = "Day " + date;
		}
	}

    void Update () {

		if (realtime) {
			UpdateContinuous();
		}
		else {
			if (isPause)
			{
				GetGapTime();
			}
			else
			{
				if (getStopTime == true)
				{
					getStopTime = false;
					initialHour += gapHour;
				}
				UpdateContinuous();
			}

		}
		
		sky.transform.rotation = Quaternion.Euler(skydegree);
		dateUI.text = "Day " + date;
	}

	public void SetPause()
	{
		isPause = !isPause;

		if (!isPause)
		{
			pauseBtn.SetActive(true);
			playBtn.SetActive(false);
		}
		else
		{
			pauseBtn.SetActive(false);
			playBtn.SetActive(true);
		}
	}


	void UpdateContinuous()
	{
		TimeSpan time = DateTime.Now.TimeOfDay;
		hoursTransform.localRotation =
			Quaternion.Euler(0f, (float)(time.TotalHours - initialHour) * degreesPerHour, 0f);
		minutesTransform.localRotation =
			Quaternion.Euler(0f, (float)(time.TotalMinutes - initialMinute) * degreesPerMinute, 0f);
		secondsTransform.localRotation =
			Quaternion.Euler(0f, (float)(time.TotalSeconds - initialSecond) * degreesPerSecond, 0f);

		//skybox
		skydegree.x = ((float)((time.TotalHours - initialHour) * degreesPerHour) / 2) % 360;

		date = 1 + (int)(((float)((time.TotalHours - initialHour) * degreesPerHour) / 2) / 360);
	}

	public double ReturnDeltaTime()
	{
        if (oldTotal == null)
        {
			Debug.Log("awsl");
			oldTotal = initialHour;
        }
        
		TimeSpan time = DateTime.Now.TimeOfDay;
		double delta = (time.TotalHours - oldTotal);
		oldTotal = time.TotalHours;

		Debug.Log(delta);
		return delta;
	}
}