// <copyright file="AsssetViewer.cs" company="beffio">
// Copyright (c) 2014 All Rights Reserved
// </copyright>
// <summary>This is script for OrbitCamera</summary>

using UnityEngine;
using System.Collections;

public class CameraControl : MonoBehaviour
{
    public Transform targetObject;
    public Vector3 targetOffset;
    public float averageDistance = 5.0f;
    public float maxDistance = 20;
    public float minDistance = .6f;
    public float xSpeed = 200.0f;
    public float ySpeed = 200.0f;
    public int yMinLimit = -80;
    public int yMaxLimit = 80;
    public int zoomSpeed = 40;
    public float panSpeed = 0.3f;
    public float zoomDampening = 5.0f;
    public float rotateOnOff = 1;

    private float xDeg = 0.0f;
    private float yDeg = 0.0f;
    private float currentDistance;
    private float desiredDistance;
    private Quaternion currentRotation;
    private Quaternion desiredRotation;
    private Quaternion rotation;
    private Vector3 position;
    private float idleTimer = 0.0f;
    private float idleSmooth = 0.0f;

    void Start() { Init(); }
    void OnEnable() { Init(); }

    public void Init()
    {
        if (!targetObject)
        {
            GameObject go = new GameObject("Cam Target");
            go.transform.position = transform.position + (transform.forward * averageDistance);
            targetObject = go.transform;
        }

        currentDistance = averageDistance;
        desiredDistance = averageDistance;

        position = transform.position;
        rotation = transform.rotation;
        currentRotation = transform.rotation;
        desiredRotation = transform.rotation;

        //xDeg = desiredRotation.eulerAngles.y;// Vector3.Angle(Vector3.right, transform.right);
        //yDeg = desiredRotation.eulerAngles.x;// Vector3.Angle(Vector3.up, transform.up);


        Vector3.Angle(Vector3.right, transform.right);
        Vector3.Angle(Vector3.up, transform.up);

        position = targetObject.position - (Quaternion.Euler(yDeg, xDeg, 0f) * Vector3.forward * currentDistance + targetOffset);
    }

    void LateUpdate()
    {
        if (targetObject != null)
        {
            if (Input.GetMouseButton(2) && Input.GetKey(KeyCode.LeftAlt) && Input.GetKey(KeyCode.LeftControl))
            {
                desiredDistance -= Input.GetAxis("Mouse Y") * 0.02f * zoomSpeed * 0.125f * Mathf.Abs(desiredDistance);
                Debug.Log(desiredDistance);
            }
            else if (Input.GetMouseButton(1))
            {
                xDeg += Input.GetAxis("Mouse X") * xSpeed * 0.02f;
                yDeg -= Input.GetAxis("Mouse Y") * ySpeed * 0.02f;
                yDeg = ClampAngle(yDeg, yMinLimit, yMaxLimit);

                desiredRotation = Quaternion.Euler(yDeg, xDeg, 0);
                currentRotation = transform.rotation;
                rotation = Quaternion.Lerp(currentRotation, desiredRotation, 0.02f * zoomDampening);
                transform.rotation = rotation;
                idleTimer = 0;
                idleSmooth = 0;

            }
            else if (Input.GetMouseButton(2))
            {

                position.x += Input.GetAxis("Mouse X") * 0.02f * zoomSpeed * 0.125f * Mathf.Abs(desiredDistance);
            }
            else
            {
                //idleTimer += 0.02f;
                //if (idleTimer > rotateOnOff && rotateOnOff > 0)
                //{
                //    idleSmooth += (0.02f + idleSmooth) * 0.005f;
                //    idleSmooth = Mathf.Clamp(idleSmooth, 0, 1);
                //    xDeg += xSpeed * 0.001f * idleSmooth;
                //}

                //yDeg = ClampAngle(yDeg, yMinLimit, yMaxLimit);
                //desiredRotation = Quaternion.Euler(yDeg, xDeg, 0);
                //currentRotation = transform.rotation;
                //rotation = Quaternion.Lerp(currentRotation, desiredRotation, 0.02f * zoomDampening * 2);
                //transform.rotation = rotation;
            }

            if (Input.GetKey(KeyCode.A)) {  }

            desiredDistance -= Input.GetAxis("Mouse ScrollWheel") * 0.02f * zoomSpeed * Mathf.Abs(desiredDistance);
            desiredDistance = Mathf.Clamp(desiredDistance, minDistance, maxDistance);
            currentDistance = Mathf.Lerp(currentDistance, desiredDistance, 0.02f * zoomDampening);
            position = targetObject.position - (rotation * Vector3.forward * currentDistance + targetOffset);
            transform.position = position;
        }
    }

    private static float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360)
            angle += 360;
        if (angle > 360)
            angle -= 360;
        return Mathf.Clamp(angle, min, max);
    }
}